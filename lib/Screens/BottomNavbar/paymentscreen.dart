import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          "Payment Details",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(child: Text("Please log in to view payment methods."))
          : StreamBuilder<QuerySnapshot>(
              // Firebase Firestore se real-time saved cards fetch kar rahe hain
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('saved_cards')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
                }

                var cardsDocs = snapshot.hasData ? snapshot.data!.docs : [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Saved Cards",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 15),

                      // --- Agar Database mein cards na hon ---
                      if (cardsDocs.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Center(
                            child: Text(
                              "No saved cards yet. Add a new card below!",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        ),

                      // --- Modern ATM Style Card List from Firestore ---
                      ListView.builder(
                        itemCount: cardsDocs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var cardData = cardsDocs[index].data() as Map<String, dynamic>;
                          String docId = cardsDocs[index].id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E1E2C), Color(0xFF2D3250)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      cardData["type"] ?? "Credit Card",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const Icon(Icons.credit_card, color: Colors.white70, size: 28),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  cardData["number"] ?? "•••• •••• •••• 0000",
                                  style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("CARD HOLDER", style: TextStyle(color: Colors.white54, fontSize: 10)),
                                        const SizedBox(height: 2),
                                        Text(cardData["holder"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("EXPIRES", style: TextStyle(color: Colors.white54, fontSize: 10)),
                                        const SizedBox(height: 2),
                                        Text(cardData["expiry"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () async {
                                        // Firestore se card delete karna
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(currentUser.uid)
                                            .collection('saved_cards')
                                            .doc(docId)
                                            .delete();

                                        Get.snackbar("Deleted", "Card removed from database", backgroundColor: Colors.black87, colorText: Colors.white, snackPosition: SnackPosition.TOP);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // --- Cash on Delivery Option Box ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.money, color: Colors.green),
                            ),
                            const SizedBox(width: 15),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Cash on Delivery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                SizedBox(height: 2),
                                Text("Pay when you receive food", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- Stylish Add New Card Button ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddCardBottomSheet(context, currentUser.uid),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.add_card, size: 20),
                          label: const Text("Add New Card", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- Modern Bottom Sheet to Save Card in Firebase ---
  void _showAddCardBottomSheet(BuildContext context, String uid) {
    final TextEditingController numController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController expController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Add New Card", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: numController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Card Number",
                  hintText: "4242 •••• •••• ••••",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Card Holder Name",
                  hintText: "Alex Morgan",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expController,
                      decoration: InputDecoration(
                        labelText: "Expires (MM/YY)",
                        hintText: "12/28",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "CVV",
                        hintText: "123",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (numController.text.isNotEmpty && nameController.text.isNotEmpty) {
                      String rawNum = numController.text.trim();
                      String maskedNum = rawNum.length >= 4 
                          ? "•••• •••• •••• ${rawNum.substring(rawNum.length - 4)}" 
                          : "•••• •••• •••• 1234";

                      // Firebase Firestore mein card save karna
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('saved_cards')
                          .add({
                        "holder": nameController.text.trim(),
                        "number": maskedNum,
                        "expiry": expController.text.trim().isNotEmpty ? expController.text.trim() : "12/28",
                        "type": "Credit Card",
                        "createdAt": FieldValue.serverTimestamp(),
                      });

                      Get.back();
                      Get.snackbar("Success", "Card saved to database successfully!", backgroundColor: Colors.black87, colorText: Colors.white, snackPosition: SnackPosition.TOP);
                    } else {
                      Get.snackbar("Error", "Please fill required fields", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save Card", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}