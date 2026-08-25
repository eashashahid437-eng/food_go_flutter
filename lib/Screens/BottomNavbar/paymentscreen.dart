import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:food_go/Constants/app_colors.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Controllers for Add Card Form
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isLoading = false;

  // Function to Add New Card to Firebase Firestore
  Future<void> _addNewCard() async {
    if (_cardNumberController.text.isEmpty ||
        _cardHolderController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all card details",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Masking card number for security display (e.g., ************1234)
    String rawCard = _cardNumberController.text.trim();
    String maskedCard = rawCard.length > 4 
        ? "**** **** **** ${rawCard.substring(rawCard.length - 4)}" 
        : rawCard;

    setState(() {
      _isLoading = true;
    });

    try {
      if (currentUser != null) {
        Map<String, dynamic> newCardData = {
          'cardNumber': maskedCard,
          'cardHolder': _cardHolderController.text.trim(),
          'expiryDate': _expiryController.text.trim(),
          'createdAt': FieldNameTimestamp(), // or FieldValue.serverTimestamp()
        };

        // Firestore ke 'savedCards' array mein card add karna
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'savedCards': FieldValue.arrayUnion([newCardData])
        });

        // Clear controllers
        _cardNumberController.clear();
        _cardHolderController.clear();
        _expiryController.clear();
        _cvvController.clear();

        Get.back(); // Close bottom sheet
        Get.snackbar(
          "Success",
          "Card added successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Agar document field na ho, toh set with merge/create use ho sakta hai
      try {
        if (currentUser != null) {
          Map<String, dynamic> newCardData = {
            'cardNumber': maskedCard,
            'cardHolder': _cardHolderController.text.trim(),
            'expiryDate': _expiryController.text.trim(),
          };
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .set({
            'savedCards': [newCardData]
          }, SetOptions(merge: true));

          _cardNumberController.clear();
          _cardHolderController.clear();
          _expiryController.clear();
          _cvvController.clear();

          Get.back();
          Get.snackbar(
            "Success",
            "Card added successfully!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (err) {
        Get.snackbar(
          "Error",
          "Failed to add card: $err",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to Delete Card from Firebase
  Future<void> _deleteCard(Map<String, dynamic> cardData) async {
    try {
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'savedCards': FieldValue.arrayRemove([cardData])
        });
        Get.snackbar(
          "Deleted",
          "Card removed successfully",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not delete card: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Show Bottom Sheet to Add Card
  void _showAddCardBottomSheet(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Add New Bank Card",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.lightwhite : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Card Number Field
                TextField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Card Number",
                    labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    prefixIcon: const Icon(Icons.credit_card, color: AppColors.Pink),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppColors.Pink, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Card Holder Name
                TextField(
                  controller: _cardHolderController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Card Holder Name",
                    labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.Pink),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppColors.Pink, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Expiry & CVV Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _expiryController,
                        keyboardType: TextInputType.datetime,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: "Expiry Date",
                          hintText: "MM/YY",
                          labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.Pink),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.Pink, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: "CVV",
                          labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.Pink),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.Pink, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addNewCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save Card",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.lightwhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.lightwhite : Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Payment Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.lightwhite : Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.Pink));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildEmptyState(context);
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>?;
            List<dynamic> savedCards = userData?['savedCards'] ?? [];

            if (savedCards.isEmpty) {
              return _buildEmptyState(context);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Saved Cards (${savedCards.length})",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // List of Real Saved Cards from Firebase
                  Expanded(
                    child: ListView.builder(
                      itemCount: savedCards.length,
                      itemBuilder: (context, index) {
                        var card = savedCards[index] as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.Pink, AppColors.Pink.withOpacity(0.75)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.Pink.withOpacity(0.3),
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
                                  const Text(
                                    "FoodGo Secure Pay",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
                                    onPressed: () => _deleteCard(card),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                card['cardNumber'] ?? "**** **** **** 0000",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "CARD HOLDER",
                                        style: TextStyle(color: Colors.white70, fontSize: 9),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        card['cardHolder'] ?? "User",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "EXPIRES",
                                        style: TextStyle(color: Colors.white70, fontSize: 9),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        card['expiryDate'] ?? "MM/YY",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "VISA",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Add New Card Button at Bottom
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddCardBottomSheet(context),
                      icon: const Icon(Icons.add_rounded, color: AppColors.Pink),
                      label: const Text(
                        "Add New Payment Card",
                        style: TextStyle(
                          color: AppColors.Pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.Pink.withOpacity(0.5), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.Pink.withOpacity(0.05),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget when no card is saved yet
  Widget _buildEmptyState(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.Pink.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.credit_card_off_rounded,
                size: 60,
                color: AppColors.Pink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No Saved Cards Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.lightwhite : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your debit or credit card to make secure payments easily.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showAddCardBottomSheet(context),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  "Add New Card",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.Pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FieldValue FieldNameTimestamp() => FieldValue.serverTimestamp();
}
