import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  final RxString email = ''.obs;
  final RxString profileImageUrl = ''.obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingImage = false.obs;

  final ImagePicker picker = ImagePicker();

  // Cloudinary
  final String cloudName = 'eyncqf0n';
  final String uploadPreset = 'ml_default';

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // ============================
  // LOAD PROFILE
  // ============================
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        isLoading.value = false;
        return;
      }

      email.value = user.email ?? '';

      final DocumentSnapshot<Map<String, dynamic>> doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        nameController.text =
            data['name']?.toString() ?? '';

        addressController.text =
            data['address']?.toString() ?? '';

        profileImageUrl.value =
            data['profileImage']?.toString() ?? '';
      } else {
        nameController.text =
            user.displayName ?? '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Profile load nahi ho saka: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // SAVE PROFILE
  // ============================
  Future<bool> saveUserData() async {
    try {
      isSaving.value = true;

      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar(
          'Error',
          'User login nahi hai.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final String userEmail =
          user.email ?? email.value;

      email.value = userEmail;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'uid': user.uid,
          'name': nameController.text.trim(),
          'email': userEmail,
          'address': addressController.text.trim(),
          'profileImage': profileImageUrl.value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      Get.snackbar(
        'Success',
        'Profile saved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Firestore Error',
        '$e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================
  // PICK IMAGE
  // ============================
  Future<void> pickImage(
    ImageSource source,
  ) async {
    try {
      isUploadingImage.value = true;

      final XFile? picked =
          await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked == null) {
        return;
      }

      final File imageFile =
          File(picked.path);

      await uploadToCloudinary(imageFile);
    } catch (e) {
      Get.snackbar(
        'Image Error',
        '$e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ============================
  // CLOUDINARY UPLOAD
  // ============================
  Future<void> uploadToCloudinary(
    File imageFile,
  ) async {
    try {
      final Uri url = Uri.parse(
        'https://api.cloudinary.com/v1_1/'
        '$cloudName/image/upload',
      );

      final request =
          http.MultipartRequest(
        'POST',
        url,
      );

      request.fields['upload_preset'] =
          uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final response =
          await request.send();

      final String body =
          await response.stream.bytesToString();

      if (response.statusCode != 200) {
        Get.snackbar(
          'Cloudinary Error',
          body,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Map<String, dynamic> result =
          jsonDecode(body);

      final String? imageUrl =
          result['secure_url']?.toString();

      if (imageUrl == null ||
          imageUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Cloudinary URL nahi mili.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // URL ko variable mein save
      profileImageUrl.value = imageUrl;

      // Firestore mein save
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(
          {
            'uid': user.uid,
            'name':
                nameController.text.trim(),
            'email':
                user.email ?? '',
            'address':
                addressController.text.trim(),
            'profileImage':
                imageUrl,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      Get.snackbar(
        'Success',
        'Profile picture uploaded and saved!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Upload Error',
        '$e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
