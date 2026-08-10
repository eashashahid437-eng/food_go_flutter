import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  // ============================================================
  // OBSERVABLE VARIABLES
  // ============================================================

  var email = ''.obs;

  var profileImageUrl = ''.obs;

  var isLoading = true.obs;

  var isSaving = false.obs;

  var isUploadingImage = false.obs;

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // CLOUDINARY
  // ============================================================

  final String cloudinaryCloudName = 'eyncqf0n';

  final String cloudinaryUploadPreset = 'ml_default';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    fetchUserData();
  }

  // ============================================================
  // FETCH USER DATA FROM FIRESTORE
  // ============================================================

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;

      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        email.value = '';
        return;
      }

      // Firebase Auth email
      email.value = currentUser.email ?? '';

      // Firestore user document
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> data =
            userDoc.data() as Map<String, dynamic>;

        nameController.text = data['name']?.toString() ?? '';

        addressController.text = data['address']?.toString() ?? '';

        profileImageUrl.value = data['profileImage']?.toString() ?? '';
      } else {
        // Agar user ka document nahi hai
        nameController.text = currentUser.displayName ?? '';

        addressController.text = '';

        profileImageUrl.value = '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to load profile data.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // SAVE USER DATA TO FIRESTORE
  // ============================================================

  Future<void> saveUserData() async {
    try {
      isSaving.value = true;

      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'Please login first.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
            'uid': currentUser.uid,

            'name': nameController.text.trim(),

            'email': currentUser.email ?? email.value,

            'address': addressController.text.trim(),

            'profileImage': profileImageUrl.value,

            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      email.value = currentUser.email ?? '';

      Get.snackbar(
        'Success',
        'Profile saved successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to save profile.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // CAMERA / GALLERY
  // ============================================================

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      // User ne image select nahi ki
      if (pickedImage == null) {
        return;
      }

      isUploadingImage.value = true;

      final File imageFile = File(pickedImage.path);

      // ========================================================
      // CLOUDINARY UPLOAD
      // ========================================================

      final Uri uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/'
        '$cloudinaryCloudName/image/upload',
      );

      final http.MultipartRequest request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = cloudinaryUploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final http.StreamedResponse streamedResponse = await request.send();

      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        final String imageUrl = jsonResponse['secure_url']?.toString() ?? '';

        if (imageUrl.isEmpty) {
          throw Exception('Cloudinary did not return image URL.');
        }

        // Image URL ko observable mein save
        profileImageUrl.value = imageUrl;

        // Firestore mein image URL save
        await _saveImageUrlToFirestore(imageUrl);

        Get.snackbar(
          'Success',
          'Profile picture uploaded successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Upload Error',
          'Cloudinary upload failed.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Image upload failed.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ============================================================
  // SAVE CLOUDINARY IMAGE URL TO FIRESTORE
  // ============================================================

  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({
          'profileImage': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to logout.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();

    super.onClose();
  }
}
