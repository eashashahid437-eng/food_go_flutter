import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final User? currentUser = FirebaseAuth.instance.currentUser;

  final ImagePicker _picker = ImagePicker();
  final LocalAuthentication auth = LocalAuthentication();

  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool biometricEnabled = false;
  bool isUploadingImage = false;

  String? selectedOrderId;
  Map<String, dynamic>? selectedOrder;

  bool _isInitialLoad = true;
  String? _lastNotifiedMessageId;

  StreamSubscription? _adminMessagesSubscription;

  @override
  void initState() {
    super.initState();

    // Chat screen khulte hi badge/unread count clear karo
    _clearUnreadBadge();

    if (currentUser != null) {
      _loadUserSettings();
      _loadSelectedOrder();
      _listenForAdminMessages();
      _markAdminMessagesAsSeen();
    }
  }

  Future<void> _markAdminMessagesAsSeen() async {
    if (currentUser == null) return;

    try {
      final unreadAdminMessages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(currentUser!.uid)
          .collection('messages')
          .where('sender', isEqualTo: 'admin')
          .where('isSeen', isEqualTo: false)
          .get();

      for (final doc in unreadAdminMessages.docs) {
        await doc.reference.update({'isSeen': true});
      }
    } catch (e) {
      debugPrint('Error marking admin messages as seen: $e');
    }
  }

  void _listenForAdminMessages() {
    if (currentUser == null) return;

    // Purana listener cancel karo (agar exist karta ho) taake duplicate na bane
    _adminMessagesSubscription?.cancel();

    _adminMessagesSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUser!.uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (_isInitialLoad) {
        if (snapshot.docs.isNotEmpty) {
          _lastNotifiedMessageId = snapshot.docs.first.id;
        }
        _isInitialLoad = false;
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added) {
          continue;
        }

        final data = change.doc.data();
        final messageId = change.doc.id;

        final String sender =
            (data?['sender'] ?? '').toString().trim().toLowerCase();

        if ((sender == 'admin' || sender == 'seller') &&
            messageId != _lastNotifiedMessageId) {
          _lastNotifiedMessageId = messageId;

          _incrementAppBadge();
        }
      }
    });
  }

  Future<void> _clearUnreadBadge() async {
    try {
      final bool isSupported = await AppBadgePlus.isSupported();

      if (isSupported) {
        await AppBadgePlus.updateBadge(0);
      }

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(currentUser!.uid)
            .set({'unreadAdminCount': 0}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Badge Clear Error: $e');
    }
  }

  Future<void> _incrementAppBadge() async {
    try {
      if (currentUser == null) return;

      final bool isSupported = await AppBadgePlus.isSupported();

      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(currentUser!.uid)
          .get();

      int unreadCount = 1;

      if (chatDoc.exists) {
        final data = chatDoc.data();
        final dynamic count = data?['unreadAdminCount'];

        if (count is int) {
          unreadCount = count;
        } else if (count is num) {
          unreadCount = count.toInt();
        }

        if (unreadCount <= 0) {
          unreadCount = 1;
        }
      }

      if (isSupported) {
        await AppBadgePlus.updateBadge(unreadCount);
      }
    } catch (e) {
      debugPrint('Badge Update Error: $e');
    }
  }

  Future<void> _loadUserSettings() async {
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data();

      if (data == null || !mounted) return;

      setState(() {
        isDarkMode = data['darkMode'] ?? false;
        notificationsEnabled = data['notificationsEnabled'] ?? true;
        biometricEnabled = data['biometricEnabled'] ?? false;
      });
    } catch (e) {
      debugPrint('Settings Error: $e');
    }
  }

  Future<void> _saveUserSettings(String? customPin) async {
    if (currentUser == null) return;

    try {
      final Map<String, dynamic> updateData = {
        'darkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
        'biometricEnabled': biometricEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (customPin != null) {
        updateData['customPin'] = customPin;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Save Settings Error: $e');
    }
  }

  void _showPinSetupDialog() {
    String tempPin = '';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setBottomSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppColors.surfaceDark : AppColors.lightwhite,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 36,
                  color: AppColors.Pink,
                ),
                const SizedBox(height: 10),
                Text(
                  'Set Your 4-Digit PIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        isDarkMode ? AppColors.lightwhite : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter a secure PIN for app protection',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final bool isFilled = index < tempPin.length;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isFilled ? AppColors.Pink : Colors.transparent,
                        border: Border.all(color: AppColors.Pink, width: 2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPinKey(
                            '1',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                          _buildPinKey(
                            '2',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                          _buildPinKey(
                            '3',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPinKey(
                            '4',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                          _buildPinKey(
                            '5',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                          _buildPinKey(
                            '6',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPinKey(
                            '7',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                          _buildPinKey(
                            '8',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                          _buildPinKey(
                            '9',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 60, height: 60),
                          _buildPinKey(
                            '0',
                            tempPin,
                            (val) => setBottomSheetState(() => tempPin = val),
                          ),
                          IconButton(
                            onPressed: () {
                              if (tempPin.isNotEmpty) {
                                setBottomSheetState(() {
                                  tempPin =
                                      tempPin.substring(0, tempPin.length - 1);
                                });
                              }
                            },
                            icon: Icon(
                              Icons.backspace_outlined,
                              color:
                                  isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPinKey(
    String number,
    String currentPin,
    Function(String) updatePin,
  ) {
    return InkWell(
      onTap: () {
        if (currentPin.length < 4) {
          final String newPin = currentPin + number;

          updatePin(newPin);

          HapticFeedback.lightImpact();

          if (newPin.length == 4) {
            Future.delayed(const Duration(milliseconds: 200), () async {
              Get.back();

              if (!mounted) return;

              setState(() {
                biometricEnabled = true;
              });

              await _saveUserSettings(newPin);

              Get.snackbar(
                'Success',
                'App Security & Custom PIN enabled',
                backgroundColor: AppColors.Pink,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.withOpacity(0.1),
        ),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.lightwhite : Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      _showPinSetupDialog();
    } else {
      setState(() {
        biometricEnabled = false;
      });

      await _saveUserSettings(null);

      Get.snackbar(
        'Disabled',
        'App Security turned off',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  Future<void> _loadSelectedOrder() async {
    final uid = currentUser?.uid;

    if (uid == null) return;

    try {
      final chatDoc =
          await FirebaseFirestore.instance.collection('chats').doc(uid).get();

      if (!chatDoc.exists) return;

      final data = chatDoc.data();

      if (data == null) return;

      final orderId = data['activeOrderId'];

      if (orderId == null || orderId.toString().isEmpty) {
        return;
      }

      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) return;

      if (mounted) {
        setState(() {
          selectedOrderId = orderDoc.id;
          selectedOrder = orderDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Order Load Error: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (currentUser == null) return;

    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    final uid = currentUser!.uid;

    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(uid)
          .collection('messages')
          .add({
        'text': text,
        'sender': 'user',
        'isSeen': false,
        'orderId': selectedOrderId,
        'orderTitle': selectedOrder?['orderTitle'] ??
            selectedOrder?['productName'] ??
            selectedOrder?['title'] ??
            'Order',
        'orderTotal': selectedOrder?['totalAmount'] ?? 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _updateChatDocument(uid: uid, lastMessage: text);

      try {
        await http.post(
          Uri.parse(
            'https://food-delivery-backend-ivory.vercel.app/api/notify-chat-message',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'recipientType': 'admin',
            'messageText': text,
            'senderName': currentUser?.email ?? 'Customer',
          }),
        );
      } catch (e) {
        debugPrint('Chat notify failed: $e');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Message could not be sent.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  Future<void> _updateChatDocument({
    required String uid,
    required String lastMessage,
  }) async {
    await FirebaseFirestore.instance.collection('chats').doc(uid).set({
      'userId': uid,
      'lastMessage': lastMessage,
      'updatedAt': FieldValue.serverTimestamp(),
      'activeOrderId': selectedOrderId,
      'activeOrderTitle': selectedOrder?['orderTitle'] ??
          selectedOrder?['productName'] ??
          selectedOrder?['title'] ??
          'Order',
      'activeOrderTotal': selectedOrder?['totalAmount'] ?? 0,
      'customerEmail': currentUser?.email ?? '',
      'unreadAdminCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> _ordersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  Future<void> _selectOrder(String orderId, Map<String, dynamic> data) async {
    if (currentUser == null) return;

    setState(() {
      selectedOrderId = orderId;
      selectedOrder = data;
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUser!.uid)
        .set({
      'activeOrderId': orderId,
      'activeOrderTitle': data['orderTitle'] ??
          data['productName'] ??
          data['title'] ??
          'Order',
      'activeOrderTotal': data['totalAmount'] ?? 0,
      'customerEmail': currentUser!.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Get.back();

    Get.snackbar(
      'Order Selected',
      'This order is now selected for support.',
      backgroundColor: Colors.white,
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) return;

      if (mounted) {
        setState(() {
          isUploadingImage = true;
        });
      }

      final File imageFile = File(photo.path);

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/eyncqf0n/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = 'ml_default';

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Cloudinary upload failed');
      }

      final responseData = jsonDecode(response.body);

      final String imageUrl = responseData['secure_url'];

      await _sendImageMessage(imageUrl);

      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
      }

      Get.snackbar(
        'Sent',
        'Photo sent successfully.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
      }

      Get.snackbar(
        'Camera Error',
        e.toString(),
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  Future<void> _sendImageMessage(String imageUrl) async {
    if (currentUser == null) return;

    final uid = currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('messages')
        .add({
      'text': '',
      'imageUrl': imageUrl,
      'messageType': 'image',
      'sender': 'user',
      'isSeen': false,
      'orderId': selectedOrderId,
      'orderTitle': selectedOrder?['orderTitle'] ??
          selectedOrder?['productName'] ??
          selectedOrder?['title'] ??
          'Order',
      'orderTotal': selectedOrder?['totalAmount'] ?? 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _updateChatDocument(uid: uid, lastMessage: '📷 Image');

    try {
      await http.post(
        Uri.parse(
          'https://food-delivery-backend-ivory.vercel.app/api/notify-chat-message',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipientType': 'admin',
          'messageText': '📷 Sent an image',
          'senderName': currentUser?.email ?? 'Customer',
        }),
      );
    } catch (e) {
      debugPrint('Chat notify failed: $e');
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.Pink.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.Pink, size: 21),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: danger
              ? AppColors.Pink
              : isDarkMode
                  ? AppColors.lightwhite
                  : Colors.black87,
        ),
      ),
      trailing: danger
          ? null
          : Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.white54 : AppColors.lightgrey,
            ),
      onTap: onTap,
    );
  }

  Widget _buildDrawer() {
    final bool dark = isDarkMode;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: dark ? AppColors.backgroundDark : AppColors.lightwhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String? profileImg;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data =
                      snapshot.data!.data() as Map<String, dynamic>;

                  profileImg = data['profileImage'] ?? data['image'];
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 25),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.darkpink, AppColors.Pink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: profileImg != null && profileImg.isNotEmpty
                              ? Image.network(
                                  profileImg,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 48,
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        currentUser?.email ?? 'Food Go User',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Food Go Customer',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          SizedBox(width: 5),
                          Text('👑', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 10),
                children: [
                  _drawerItem(
                    icon: Icons.bookmark_border,
                    title: 'Orders',
                    onTap: () {
                      Navigator.pop(context);
                      _showOrderHistory();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.location_on_outlined,
                    title: 'Addresses',
                    onTap: () {
                      Navigator.pop(context);
                      _showAddresses();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.credit_card,
                    title: 'Payment Details',
                    onTap: () {
                      Navigator.pop(context);
                      _showPaymentDetails();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.headset_mic_outlined,
                    title: 'Live Support',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(
                      color: dark ? AppColors.surfaceDark : AppColors.lightgrey,
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.camera_alt_outlined,
                    title: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.Pink.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        dark ? Icons.dark_mode : Icons.nightlight_outlined,
                        color: AppColors.Pink,
                        size: 21,
                      ),
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: dark ? AppColors.lightwhite : Colors.black87,
                      ),
                    ),
                    trailing: Switch(
                      value: isDarkMode,
                      activeThumbColor: AppColors.Pink,
                      onChanged: (value) async {
                        setState(() {
                          isDarkMode = value;
                        });

                        Get.changeThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );

                        await _saveUserSettings(null);
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.Pink.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: AppColors.Pink,
                        size: 21,
                      ),
                    ),
                    title: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: dark ? AppColors.lightwhite : Colors.black87,
                      ),
                    ),
                    trailing: Switch(
                      value: notificationsEnabled,
                      activeThumbColor: AppColors.Pink,
                      onChanged: (value) async {
                        setState(() {
                          notificationsEnabled = value;
                        });

                        await _saveUserSettings(null);
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.Pink.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        color: AppColors.Pink,
                        size: 21,
                      ),
                    ),
                    title: Text(
                      'App Security',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: dark ? AppColors.lightwhite : Colors.black87,
                      ),
                    ),
                    trailing: Switch(
                      value: biometricEnabled,
                      activeThumbColor: AppColors.Pink,
                      onChanged: (value) => _handleBiometricToggle(value),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(
                      color: dark ? AppColors.surfaceDark : AppColors.lightgrey,
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      _showPrivacyPolicy();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {
                      Navigator.pop(context);
                      _showTerms();
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(
                      color: dark ? AppColors.surfaceDark : AppColors.lightgrey,
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    danger: true,
                    onTap: () {
                      Navigator.pop(context);
                      _logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderHistory() {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: darkColorThemeCheck(AppColors.surfaceDark, AppColors.lightwhite),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.lightgrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Orders',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.lightwhite : Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _ordersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.Pink),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to load orders.',
                        style: TextStyle(
                          color: isDarkMode ? AppColors.lightwhite : Colors.black,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No orders found.',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    );
                  }

                  final orders = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final doc = orders[index];

                      final data = doc.data() as Map<String, dynamic>;

                      final title = data['orderTitle'] ??
                          data['productName'] ??
                          data['title'] ??
                          'Food Order';

                      final total = data['totalAmount'] ?? 0;

                      final status = data['status'] ?? 'Pending';

                      String formattedDateTime = '';

                      if (data['timestamp'] != null) {
                        final Timestamp timestamp = data['timestamp'];

                        final DateTime dateTime = timestamp.toDate();

                        formattedDateTime =
                            DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.lightgrey.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.Pink,
                            child: Icon(Icons.fastfood, color: Colors.white),
                          ),
                          title: Text(
                            title.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode ? AppColors.lightwhite : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Total: \$${_formatNumber(total)}\n'
                            'Status: $status'
                            '${formattedDateTime.isNotEmpty ? '\nDate: $formattedDateTime' : ''}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _selectOrder(doc.id, data);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.Pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Chat',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Color darkColorThemeCheck(Color darkColor, Color lightColor) {
    return isDarkMode ? darkColor : lightColor;
  }

  void _showAddresses() {
    if (currentUser == null) return;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: darkColorThemeCheck(AppColors.surfaceDark, AppColors.lightwhite),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Icon(Icons.location_on, color: AppColors.Pink, size: 32),
            const SizedBox(height: 8),
            Text(
              'Addresses',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.lightwhite : Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('addresses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.Pink),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to load addresses.',
                        style: TextStyle(
                          color: isDarkMode ? AppColors.lightwhite : Colors.black,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No saved addresses.',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      return Card(
                        color: darkColorThemeCheck(
                          AppColors.surfaceDark,
                          AppColors.lightwhite,
                        ),
                        child: ListTile(
                          leading: Icon(Icons.location_on, color: AppColors.Pink),
                          title: Text(
                            data['title'] ?? data['address'] ?? 'Address',
                            style: TextStyle(
                              color: isDarkMode ? AppColors.lightwhite : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            data['address'] ?? data['location'] ?? '',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _showPaymentDetails() async {
    if (currentUser == null) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: darkColorThemeCheck(AppColors.surfaceDark, AppColors.lightwhite),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.Pink),
                ),
              );
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;

            final payment = data?['paymentMethod'] ??
                data?['paymentDetails'] ??
                'No payment method saved';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.credit_card, color: AppColors.Pink, size: 38),
                const SizedBox(height: 10),
                Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.lightwhite : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.Pink.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    payment.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode ? AppColors.lightwhite : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    _showInfoDialog(
      'Privacy Policy',
      'Your Food Go account information and order data are stored securely in Firebase and are used to provide ordering and support services.',
    );
  }

  void _showTerms() {
    _showInfoDialog(
      'Terms & Conditions',
      'By using Food Go, you agree to use the application responsibly and provide accurate information for orders and delivery.',
    );
  }

  void _showInfoDialog(String title, String text) {
    Get.dialog(
      AlertDialog(
        backgroundColor: darkColorThemeCheck(AppColors.surfaceDark, AppColors.lightwhite),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? AppColors.lightwhite : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          text,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close', style: TextStyle(color: AppColors.Pink)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value is num) {
      return value.toStringAsFixed(2);
    }

    return double.tryParse(value.toString())?.toStringAsFixed(2) ?? '0.00';
  }

  Widget _buildMessage(DocumentSnapshot message) {
    final data = message.data() as Map<String, dynamic>;

    final bool isMe = data['sender'] == 'user';

    final bool isSeen = data['isSeen'] ?? false;

    final String? imageUrl = data['imageUrl'];

    return GestureDetector(
      onLongPress: isMe ? () => _deleteMessage(message.id) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.support_agent, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(10),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.Pink
                      : isDarkMode
                          ? AppColors.surfaceDark
                          : AppColors.lightgrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['orderId'] != null)
                      Container(
                        padding: const EdgeInsets.all(7),
                        margin: const EdgeInsets.only(bottom: 7),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Order: ${data['orderTitle'] ?? 'Order'}\n'
                          'ID: ${data['orderId']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 220,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                    if ((data['text'] ?? '').toString().isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              data['text'] ?? '',
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : isDarkMode
                                        ? AppColors.lightwhite
                                        : Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.done_all,
                            size: 14,
                            color: isSeen
                                ? Colors.blue
                                : (isMe ? Colors.white60 : Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String? profileImg;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    profileImg = userData['profileImage'] ?? userData['image'];
                  }

                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.lightgrey,
                    child: ClipOval(
                      child: profileImg != null && profileImg.isNotEmpty
                          ? Image.network(
                              profileImg,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.Pink,
                              ),
                            )
                          : Icon(Icons.person, size: 18, color: AppColors.Pink),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please login first.')),
      );
    }

    final uid = currentUser!.uid;

    return Scaffold(
      backgroundColor: darkColorThemeCheck(AppColors.backgroundDark, AppColors.lightwhite),
      endDrawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: darkColorThemeCheck(AppColors.backgroundDark, AppColors.lightwhite),
        foregroundColor: isDarkMode ? AppColors.lightwhite : Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const SizedBox(),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, size: 30),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(uid)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.Pink),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Chat error: ${snapshot.error}',
                      style: TextStyle(
                        color: isDarkMode ? AppColors.lightwhite : Colors.black,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Start chatting with support.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(messages[index]);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: AppColors.Pink,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: isUploadingImage
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 21),
                      onPressed: isUploadingImage ? null : _takePhoto,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: darkColorThemeCheck(
                          AppColors.surfaceDark,
                          AppColors.surfaceLight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: isDarkMode ? AppColors.lightwhite : Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type here...',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.Pink,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 23),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();

    _adminMessagesSubscription?.cancel();

    super.dispose();
  }
}
