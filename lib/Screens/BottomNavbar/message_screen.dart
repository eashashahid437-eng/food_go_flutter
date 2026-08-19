import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:food_go/Auth/Login_Screen.dart';

// Global notification plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final User? currentUser = FirebaseAuth.instance.currentUser;

  final ImagePicker _picker = ImagePicker();

  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool isUploadingImage = false;

  String? selectedOrderId;
  Map<String, dynamic>? selectedOrder;

  // Variables to prevent duplicate notifications on screen load
  bool _isInitialLoad = true;
  String? _lastNotifiedMessageId;

  @override
  void initState() {
    super.initState();

    _initLocalNotifications();
    _clearUnreadBadge();

    if (currentUser != null) {
      _loadUserSettings();
      _loadSelectedOrder();
      _listenForAdminMessages();
      _markAdminMessagesAsSeen(); // <-- Admin ke messages ko seen mark karne ke liye yahan call kar diya hai
    }

    // Foreground FCM Notification Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && notificationsEnabled) {
        Get.snackbar(
          message.notification!.title ?? 'FoodGo',
          message.notification!.body ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.Pink,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  // Admin ke bheje hue unread messages ko 'seen' (true) karne ka function
  void _markAdminMessagesAsSeen() async {
    if (currentUser == null) return;
    try {
      var unreadAdminMessages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(currentUser!.uid)
          .collection('messages')
          .where('sender', isEqualTo: 'admin')
          .where('isSeen', isEqualTo: false)
          .get();

      for (var doc in unreadAdminMessages.docs) {
        doc.reference.update({'isSeen': true});
      }
    } catch (e) {
      debugPrint("Error marking admin messages as seen: $e");
    }
  }

  // Local Notifications Initialize karna (Reply action remove kar diya gaya hai)
  void _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Firestore se Admin ke naye messages detect karke local notification aur app badge update karne ka function
  void _listenForAdminMessages() {
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUser!.uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      
      // Jab bhi naya message aaye aur user chat screen par ho, turant seen mark kar do
      _markAdminMessagesAsSeen();

      if (_isInitialLoad) {
        if (snapshot.docs.isNotEmpty) {
          _lastNotifiedMessageId = snapshot.docs.first.id;
        }
        _isInitialLoad = false;
        return;
      }

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var data = change.doc.data();
          String messageId = change.doc.id;
          
          String sender = (data?['sender'] ?? '').toString().trim().toLowerCase();
          
          if ((sender == 'admin' || sender == 'seller') && messageId != _lastNotifiedMessageId) {
            _lastNotifiedMessageId = messageId;

            _incrementAppBadge();

            if (notificationsEnabled) {
              String messageText = data?['text'] ?? '';
              if (messageText.isEmpty && data?['imageUrl'] != null) {
                messageText = '📷 Sent an image';
              }

              _showLocalNotification(
                "FoodGo",
                messageText.isNotEmpty ? messageText : "You have a new message",
              );
            }
          }
        }
      }
    });
  }

  Future<void> _clearUnreadBadge() async {
    try {
      bool isSupported = await AppBadgePlus.isSupported();
      if (isSupported) {
        AppBadgePlus.updateBadge(0);
      }

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(currentUser!.uid)
            .update({'unreadAdminCount': 0});
      }
    } catch (e) {
      debugPrint("Badge Clear Error: $e");
    }
  }

  Future<void> _incrementAppBadge() async {
    try {
      bool isSupported = await AppBadgePlus.isSupported();
      if (isSupported && currentUser != null) {
        var chatDoc = await FirebaseFirestore.instance
            .collection('chats')
            .doc(currentUser!.uid)
            .get();
        
        if (chatDoc.exists) {
          int unreadCount = chatDoc.data()?['unreadAdminCount'] ?? 1;
          AppBadgePlus.updateBadge(unreadCount);
        }
      }
    } catch (e) {
      debugPrint("Badge Update Error: $e");
    }
  }

  // Local Notification pop-up (Bina reply action ke)
  void _showLocalNotification(String title, String body) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'admin_chat_channel',
      'Admin Chat Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: 'chat_notification',
    );
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
      });
    } catch (e) {
      debugPrint("Settings Error: $e");
    }
  }

  Future<void> _saveUserSettings() async {
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set({
            'darkMode': isDarkMode,
            'notificationsEnabled': notificationsEnabled,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Save Settings Error: $e");
    }
  }

  Future<void> _loadSelectedOrder() async {
    final uid = currentUser?.uid;

    if (uid == null) return;

    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(uid)
          .get();

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
      debugPrint("Order Load Error: $e");
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
            'isSeen': false, // Blue tick status field added
            'orderId': selectedOrderId,
            'orderTitle':
                selectedOrder?['orderTitle'] ??
                selectedOrder?['productName'] ??
                selectedOrder?['title'] ??
                'Order',
            'orderTotal': selectedOrder?['totalAmount'] ?? 0,
            'timestamp': FieldValue.serverTimestamp(),
          });

      await _updateChatDocument(uid: uid, lastMessage: text);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Message could not be sent.",
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
      'activeOrderTitle':
          selectedOrder?['orderTitle'] ??
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
          'activeOrderTitle':
              data['orderTitle'] ??
              data['productName'] ??
              data['title'] ??
              'Order',
          'activeOrderTotal': data['totalAmount'] ?? 0,
          'customerEmail': currentUser!.email ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    Get.back();

    Get.snackbar(
      "Order Selected",
      "This order is now selected for support.",
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
        throw Exception("Cloudinary upload failed");
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
        "Sent",
        "Photo sent successfully.",
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
        "Camera Error",
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
          'isSeen': false, // Blue tick status field added
          'orderId': selectedOrderId,
          'orderTitle':
              selectedOrder?['orderTitle'] ??
              selectedOrder?['productName'] ??
              selectedOrder?['title'] ??
              'Order',
          'orderTotal': selectedOrder?['totalAmount'] ?? 0,
          'timestamp': FieldValue.serverTimestamp(),
        });

    await _updateChatDocument(uid: uid, lastMessage: '📷 Image');
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
        "Error",
        "Logout failed.",
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
                  var data = snapshot.data!.data() as Map<String, dynamic>?;
                  profileImg = data?['profileImage'] ?? data?['image'];
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.darkpink, AppColors.Pink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
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
                        currentUser?.email ?? "Food Go User",
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
                            "Food Go Customer",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text("👑", style: TextStyle(fontSize: 15)),
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
                    title: "Orders",
                    onTap: () {
                      Navigator.pop(context);
                      _showOrderHistory();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.location_on_outlined,
                    title: "Addresses",
                    onTap: () {
                      Navigator.pop(context);
                      _showAddresses();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.credit_card,
                    title: "Payment Details",
                    onTap: () {
                      Navigator.pop(context);
                      _showPaymentDetails();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.headset_mic_outlined,
                    title: "Live Support",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: dark ? AppColors.surfaceDark : AppColors.lightgrey),
                  ),
                  _drawerItem(
                    icon: Icons.camera_alt_outlined,
                    title: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
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
                      "Dark Mode",
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
                        
                        Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

                        await _saveUserSettings();
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
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
                      "Notifications",
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
                        await _saveUserSettings();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: dark ? AppColors.surfaceDark : AppColors.lightgrey),
                  ),
                  _drawerItem(
                    icon: Icons.shield_outlined,
                    title: "Privacy Policy",
                    onTap: () {
                      Navigator.pop(context);
                      _showPrivacyPolicy();
                    },
                  ),
                  _drawerItem(
                    icon: Icons.description_outlined,
                    title: "Terms & Conditions",
                    onTap: () {
                      Navigator.pop(context);
                      _showTerms();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: dark ? AppColors.surfaceDark : AppColors.lightgrey),
                  ),
                  _drawerItem(
                    icon: Icons.logout,
                    title: "Logout",
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
              "Orders",
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
                        "Unable to load orders.",
                        style: TextStyle(
                          color: isDarkMode ? AppColors.lightwhite : Colors.black,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No orders found.",
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

                      final title =
                          data['orderTitle'] ??
                          data['productName'] ??
                          data['title'] ??
                          'Food Order';

                      final total = data['totalAmount'] ?? 0;
                      final status = data['status'] ?? 'Pending';

                      String formattedDateTime = '';
                      if (data['timestamp'] != null) {
                        Timestamp timestamp = data['timestamp'];
                        DateTime dateTime = timestamp.toDate();
                        formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.lightgrey.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.Pink,
                            child: const Icon(Icons.fastfood, color: Colors.white),
                          ),
                          title: Text(
                            title.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? AppColors.lightwhite : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            "Total: \$${_formatNumber(total)}\n"
                            "Status: $status"
                            "${formattedDateTime.isNotEmpty ? '\nDate: $formattedDateTime' : ''}",
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
                              "Chat",
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
              "Addresses",
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
                        "Unable to load addresses.",
                        style: TextStyle(color: isDarkMode ? AppColors.lightwhite : Colors.black),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No saved addresses.",
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;

                      return Card(
                        color: darkColorThemeCheck(AppColors.surfaceDark, AppColors.lightwhite),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: AppColors.Pink,
                          ),
                          title: Text(
                            data['title'] ?? data['address'] ?? 'Address',
                            style: TextStyle(color: isDarkMode ? AppColors.lightwhite : Colors.black),
                          ),
                          subtitle: Text(
                            data['address'] ?? data['location'] ?? '',
                            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
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

            final payment =
                data?['paymentMethod'] ??
                data?['paymentDetails'] ??
                'No payment method saved';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.credit_card, color: AppColors.Pink, size: 38),
                const SizedBox(height: 10),
                Text(
                  "Payment Details",
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
      "Privacy Policy",
      "Your Food Go account information and order data are stored securely in Firebase and are used to provide ordering and support services.",
    );
  }

  void _showTerms() {
    _showInfoDialog(
      "Terms & Conditions",
      "By using Food Go, you agree to use the application responsibly and provide accurate information for orders and delivery.",
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
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Close", style: TextStyle(color: AppColors.Pink)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value is num) {
      return value.toStringAsFixed(2);
    }

    return double.tryParse(value.toString())?.toStringAsFixed(2) ?? "0.00";
  }

  Widget _buildMessage(DocumentSnapshot message) {
    final data = message.data() as Map<String, dynamic>;

    final bool isMe = data['sender'] == 'user';
    final bool isSeen = data['isSeen'] ?? false; // Read status fetch kar rahe hain

    final String? imageUrl = data['imageUrl'];

    return GestureDetector(
      onLongPress: isMe ? () => _deleteMessage(message.id) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
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
                          "Order: ${data['orderTitle'] ?? 'Order'}\n"
                          "ID: ${data['orderId']}",
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
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 60);
                          },
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
                          // Ab user aur admin dono ke messages ke neechay ticks show honge
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
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    profileImg =
                        userData?['profileImage'] ?? userData?['image'];
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
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.Pink,
                                  ),
                            )
                          : Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.Pink,
                            ),
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
      return const Scaffold(body: Center(child: Text("Please login first.")));
    }

    final uid = currentUser!.uid;
    
    // Har baar screen build hone par bhi admin messages ko seen mark kar do
    _markAdminMessagesAsSeen();

    return Scaffold(
      backgroundColor: darkColorThemeCheck(AppColors.backgroundDark, AppColors.lightwhite),

      endDrawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: darkColorThemeCheck(AppColors.backgroundDark, AppColors.lightwhite),
        foregroundColor: isDarkMode ? AppColors.lightwhite : Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: null,
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
                      "Chat error: ${snapshot.error}",
                      style: TextStyle(color: isDarkMode ? AppColors.lightwhite : Colors.black),
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
                      "Start chatting with support.",
                      style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey),
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
                    decoration: BoxDecoration(
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
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 21,
                            ),
                      onPressed: isUploadingImage ? null : _takePhoto,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: darkColorThemeCheck(AppColors.surfaceDark, AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: isDarkMode ? AppColors.lightwhite : Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Type here...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.Pink,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 23,
                      ),
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
    super.dispose();
  }
}
