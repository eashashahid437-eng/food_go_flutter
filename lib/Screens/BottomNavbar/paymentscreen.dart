import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_go/Constants/app_colors.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Payment Details",
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: currentUser == null
          ? const Center(
              child: Text(
                "Please log in to view payment details.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('saved_cards')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkpink,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 45,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Unable to load payment details.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    cardsDocs = snapshot.data?.docs ?? [];

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment Methods",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Manage your saved payment methods",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Saved Cards",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                            ),
                          ),
                          if (cardsDocs.isNotEmpty)
                            Text(
                              "${cardsDocs.length} card${cardsDocs.length == 1 ? '' : 's'}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (cardsDocs.isEmpty) _buildEmptyCard(isDark),
                      if (cardsDocs.isNotEmpty)
                        ListView.builder(
                          itemCount: cardsDocs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final doc = cardsDocs[index];
                            final Map<String, dynamic> cardData = doc.data();

                            return _buildSavedCard(
                              context: context,
                              cardData: cardData,
                              docId: doc.id,
                              uid: currentUser.uid,
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                      Text(
                        "Other Payment Option",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCashOnDelivery(isDark),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showAddCardBottomSheet(
                              context,
                              currentUser.uid,
                              isDark,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.primaryLight : Colors.black87,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add_card,
                            size: 21,
                          ),
                          label: const Text(
                            "Add New Card",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.darkpink.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_off_outlined,
              color: AppColors.darkpink,
              size: 30,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "No saved cards yet",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Add a card to make future payments easier.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard({
    required BuildContext context,
    required Map<String, dynamic> cardData,
    required String docId,
    required String uid,
  }) {
    final String cardType = (cardData["type"] ?? "Credit Card").toString();
    final String cardNumber = (cardData["number"] ?? "•••• •••• •••• 0000").toString();
    final String holder = (cardData["holder"] ?? "Card Holder").toString();
    final String expiry = (cardData["expiry"] ?? "--/--").toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1E2C),
            Color(0xFF2D3250),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.credit_card,
                color: Colors.white70,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            cardNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CARD HOLDER",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      holder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "EXPIRES",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expiry,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 35,
                  minHeight: 35,
                ),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 21,
                ),
                onPressed: () {
                  _confirmDeleteCard(
                    context: context,
                    uid: uid,
                    docId: docId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashOnDelivery(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.money,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cash on Delivery",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "Pay when you receive your food",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCard({
    required BuildContext context,
    required String uid,
    required String docId,
  }) {
    final bool isDark = Get.isDarkMode;
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          "Delete Card?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          "Are you sure you want to remove this saved card?",
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _deleteCard(
                uid: uid,
                docId: docId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCard({
    required String uid,
    required String docId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('saved_cards')
          .doc(docId)
          .delete();

      Get.snackbar(
        "Deleted",
        "Card removed successfully.",
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not delete the card.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  void _showAddCardBottomSheet(
    BuildContext context,
    String uid,
    bool isDark,
  ) {
    final TextEditingController numController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController expController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add New Card",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? AppColors.lightwhite : Colors.black,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your card details",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: numController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  style: TextStyle(color: isDark ? AppColors.lightwhite : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Card Number",
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: "1234 5678 9012 3456",
                    counterText: "",
                    prefixIcon: const Icon(Icons.credit_card, color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? AppColors.backgroundDark : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: isDark ? AppColors.lightwhite : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Card Holder Name",
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: "Alex Morgan",
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? AppColors.backgroundDark : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        style: TextStyle(color: isDark ? AppColors.lightwhite : Colors.black),
                        decoration: InputDecoration(
                          labelText: "Expires",
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintText: "MM/YY",
                          counterText: "",
                          filled: true,
                          fillColor: isDark ? AppColors.backgroundDark : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        style: TextStyle(color: isDark ? AppColors.lightwhite : Colors.black),
                        decoration: InputDecoration(
                          labelText: "CVV",
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintText: "123",
                          counterText: "",
                          filled: true,
                          fillColor: isDark ? AppColors.backgroundDark : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 15,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        "For security, your full card number and CVV are not stored.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final String rawNum = numController.text.trim();
                      final String holder = nameController.text.trim();
                      final String expiry = expController.text.trim();

                      if (rawNum.length < 4) {
                        Get.snackbar(
                          "Invalid Card",
                          "Please enter a valid card number.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      if (holder.isEmpty) {
                        Get.snackbar(
                          "Required",
                          "Please enter card holder name.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      if (expiry.isEmpty) {
                        Get.snackbar(
                          "Required",
                          "Please enter expiry date.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      final String digitsOnly = rawNum.replaceAll(RegExp(r'\D'), '');
                      final String lastFour = digitsOnly.length >= 4
                          ? digitsOnly.substring(digitsOnly.length - 4)
                          : digitsOnly;
                      final String maskedNumber = "•••• •••• •••• $lastFour";

                      Get.dialog(
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        barrierDismissible: false,
                      );

                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('saved_cards')
                            .add({
                          "holder": holder,
                          "number": maskedNumber,
                          "expiry": expiry,
                          "type": "Credit Card",
                          "createdAt": FieldValue.serverTimestamp(),
                        });

                        if (Get.isDialogOpen ?? false) {
                          Get.back();
                        }

                        Get.back();

                        Get.snackbar(
                          "Success",
                          "Card saved successfully.",
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(12),
                        );
                      } catch (e) {
                        if (Get.isDialogOpen ?? false) {
                          Get.back();
                        }

                        Get.snackbar(
                          "Error",
                          "Could not save the card. Please try again.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(12),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryLight : Colors.black87,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Card",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
