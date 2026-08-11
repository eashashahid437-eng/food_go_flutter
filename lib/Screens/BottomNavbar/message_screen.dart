import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Message Send karne ka function
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUser == null) return;

    String msg = _messageController.text.trim();
    _messageController.clear();

    String uid = currentUser!.uid;

    // 1. Messages sub-collection mein message add karna
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('messages')
        .add({
      'text': msg,
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Chat room ka last message update karna taake admin ko inbox mein nazar aaye
    await FirebaseFirestore.instance.collection('chats').doc(uid).set({
      'lastMessage': msg,
      'userName': currentUser!.displayName ?? 'App User',
      'userEmail': currentUser!.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Database se sari chat clear karne ka function
  void _clearChat(String uid) async {
    Get.back(); // Menu close karne ke liye
    Get.defaultDialog(
      title: "Clear Chat",
      middleText: "Kya aap waqai saari chat history delete karna chahte hain?",
      textConfirm: "Yes, Delete",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFFF2442),
      textCancel: "Cancel",
      onConfirm: () async {
        Get.back(); // Dialog band karein
        var messagesRef = FirebaseFirestore.instance
            .collection('chats')
            .doc(uid)
            .collection('messages');
        
        var snapshots = await messagesRef.get();
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }

        // Last message bhi chat document se clear kar dein
        await FirebaseFirestore.instance.collection('chats').doc(uid).update({
          'lastMessage': 'Chat cleared',
        });

        Get.snackbar("Success", "Chat history cleared successfully.",
            backgroundColor: Colors.green, colorText: Colors.white);
      },
    );
  }

  // Real Database se Order details fetch karne ka function
  void _showOrderDetails() async {
    Get.back(); // Menu close karein

    // Loading indicator dikhayein jab tak data fetch ho raha ho
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF2442)),
      ),
    );

    try {
      // Firestore se is user ka sab se latest order fetch kar rahe hain
      var orderSnapshot = await FirebaseFirestore.instance
          .collection('orders') // Apne orders collection ka naam yahan check kar lein
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      Navigator.pop(context); // Loading dialog band karein

      if (orderSnapshot.docs.isEmpty) {
        Get.snackbar(
          "No Order Found",
          "Aapka koi active order mojood nahi hai.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      var orderData = orderSnapshot.docs.first.data();
      String orderId = orderSnapshot.docs.first.id;
      
      // Database fields (aap apne database ke field names ke mutabiq inhein adjust kar sakti hain)
      String items = orderData['itemsName'] ?? orderData['productName'] ?? 'Burger / Food Item';
      String status = orderData['status'] ?? 'Pending';
      String total = orderData['totalPrice']?.toString() ?? '0';
      String address = orderData['deliveryAddress'] ?? 'N/A';

      // Real Data Dialog Box
      Get.defaultDialog(
        title: "Order Details",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: #$orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Items: $items"),
            const SizedBox(height: 8),
            Text("Status: $status", style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Total Amount: Rs $total"),
            const SizedBox(height: 8),
            Text("Address: $address"),
          ],
        ),
        textConfirm: "Close",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFFF2442),
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      Navigator.pop(context); // Agar error aaye toh loading band kar dein
      Get.snackbar(
        "Error",
        "No Order Found",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Issue report karne ka function
  void _reportIssue(String uid) async {
    Get.back();
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('messages')
        .add({
      'text': '[System Notification]: User reported an issue with this order.',
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });
    Get.snackbar("Reported", "System Notification: User reported an issue with this order.",
        backgroundColor: Colors.black38, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please login first to chat.")),
      );
    }

    String uid = currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Professional Popup Menu (WhatsApp Style)
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (value) {
              if (value == 'clear') {
                _clearChat(uid);
              } else if (value == 'order') {
                _showOrderDetails();
              } else if (value == 'report') {
                _reportIssue(uid);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'order',
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: Colors.black54, size: 20),
                    SizedBox(width: 10),
                    Text('View Order Details'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report_problem_outlined, color: Colors.orange, size: 20),
                    SizedBox(width: 10),
                    Text('Report Issue'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text('Clear Chat', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages ListView with Live StreamBuilder
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Hi, how can I help you?",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var data = messages[index].data() as Map<String, dynamic>;
                    bool isMe = data['sender'] == 'user';

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                      builder: (context, userSnapshot) {
                        String? profilePic;
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          profilePic = userData['profileImage'] ?? currentUser?.photoURL;
                        } else {
                          profilePic = currentUser?.photoURL;
                        }

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe) ...[
                                const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.person, size: 18, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isMe ? const Color(0xFFFF2442) : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    data['text'] ?? '',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: profilePic != null && profilePic.isNotEmpty
                                      ? NetworkImage(profilePic)
                                      : const AssetImage('assets/images/appbarpic.png') as ImageProvider,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Typing Input Field & Send Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type here...',
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2442),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
