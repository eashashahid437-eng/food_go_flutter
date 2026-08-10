import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final RxBool notificationsEnabled = true.obs;
  final RxBool emailNotifications = true.obs;
  final RxBool orderNotifications = true.obs;
  final RxBool promotionalNotifications = false.obs;

  final RxBool isLoading = false.obs;

  User? get currentUser => auth.currentUser;

  String get uid => currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> loadSettings() async {
    if (uid.isEmpty) return;

    try {
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists) {
        final data = doc.data();

        notificationsEnabled.value =
            data?['notificationsEnabled'] ?? true;

        emailNotifications.value =
            data?['emailNotifications'] ?? true;

        orderNotifications.value =
            data?['orderNotifications'] ?? true;

        promotionalNotifications.value =
            data?['promotionalNotifications'] ?? false;
      }
    } catch (e) {
      debugPrint('Settings load error: $e');
    }
  }

  // ============================================================
  // SAVE NOTIFICATION SETTINGS
  // ============================================================

  Future<void> saveNotificationSettings() async {
    if (uid.isEmpty) return;

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('preferences')
          .set({
        'notificationsEnabled': notificationsEnabled.value,
        'emailNotifications': emailNotifications.value,
        'orderNotifications': orderNotifications.value,
        'promotionalNotifications':
            promotionalNotifications.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to save notification settings.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // NOTIFICATION TOGGLE
  // ============================================================

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await saveNotificationSettings();
  }

  Future<void> toggleEmailNotifications(bool value) async {
    emailNotifications.value = value;
    await saveNotificationSettings();
  }

  Future<void> toggleOrderNotifications(bool value) async {
    orderNotifications.value = value;
    await saveNotificationSettings();
  }

  Future<void> togglePromotionalNotifications(bool value) async {
    promotionalNotifications.value = value;
    await saveNotificationSettings();
  }

  // ============================================================
  // ADD ADDRESS
  // ============================================================

  Future<void> addAddress({
    required String title,
    required String address,
  }) async {
    if (uid.isEmpty) return;

    if (address.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .add({
        'title': title.trim().isEmpty ? 'Home' : title.trim(),
        'address': address.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back();

      Get.snackbar(
        'Success',
        'Address added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to add address.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // DELETE ADDRESS
  // ============================================================

  Future<void> deleteAddress(String documentId) async {
    if (uid.isEmpty) return;

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .doc(documentId)
          .delete();

      Get.snackbar(
        'Deleted',
        'Address removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to delete address.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> changePassword(String newPassword) async {
    if (currentUser == null) return;

    if (newPassword.length < 6) {
      Get.snackbar(
        'Error',
        'Password must contain at least 6 characters.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await currentUser!.updatePassword(newPassword);

      Get.back();

      Get.snackbar(
        'Success',
        'Password updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Unable to change password.';

      if (e.code == 'requires-recent-login') {
        message =
            'For security, please login again before changing password.';
      }

      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await auth.signOut();

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to logout.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}