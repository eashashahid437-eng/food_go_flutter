
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

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  // ============================================================
  // OBSERVABLE VARIABLES
  // ============================================================

  final RxString email = ''.obs;

  final RxString profileImageUrl = ''.obs;

  final RxBool isLoading = true.obs;

  final RxBool isSaving = false.obs;

  final RxBool isUploadingImage = false.obs;

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
  // GET CURRENT USER
  // ============================================================

  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  // ============================================================
  // FETCH USER DATA FROM FIRESTORE
  // ============================================================

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;

      final User? user = FirebaseAuth.instance.currentUser;

      // User login nahi hai
      if (user == null) {
        email.value = '';
        nameController.clear();
        addressController.clear();
        profileImageUrl.value = '';
        return;
      }

      // Firebase Authentication se email
      email.value = user.email ?? '';

      // Firestore se user data
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> data =
            userDoc.data() as Map<String, dynamic>;

        nameController.text =
            data['name']?.toString() ?? '';

        addressController.text =
            data['address']?.toString() ?? '';

        profileImageUrl.value =
            data['profileImage']?.toString() ?? '';
      } else {
        // Agar Firestore mein document nahi hai
        nameController.text =
            user.displayName ?? '';

        addressController.clear();

        profileImageUrl.value = '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to load profile data.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // SAVE PROFILE DATA
  // ============================================================

  Future<void> saveUserData() async {
    try {
      isSaving.value = true;

      final User? user =
          FirebaseAuth.instance.currentUser;

      // User login nahi hai
      if (user == null) {
        Get.snackbar(
          'Error',
          'User is not logged in.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        return;
      }

      // Firestore mein data save
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'uid': user.uid,
          'name': nameController.text.trim(),
          'email': user.email ?? email.value,
          'address': addressController.text.trim(),
          'profileImage': profileImageUrl.value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Email update
      email.value = user.email ?? '';

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
        'Unable to save profile data.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
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
      // Image picker open
      final XFile? pickedImage =
          await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      // User ne cancel kar diya
      if (pickedImage == null) {
        return;
      }

      isUploadingImage.value = true;

      final File imageFile =
          File(pickedImage.path);

      // ========================================================
      // CLOUDINARY URL
      // ========================================================

      final Uri uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/'
        '$cloudinaryCloudName/image/upload',
      );

      // Multipart request
      final http.MultipartRequest request =
          http.MultipartRequest(
        'POST',
        uri,
      );

      // Upload preset
      request.fields['upload_preset'] =
          cloudinaryUploadPreset;

      // Image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Cloudinary ko request send
      final http.StreamedResponse
          streamedResponse =
          await request.send();

      final http.Response response =
          await http.Response.fromStream(
        streamedResponse,
      );

      // ========================================================
      // CLOUDINARY SUCCESS
      // ========================================================

      if (response.statusCode == 200) {
        final Map<String, dynamic>
            jsonResponse =
            jsonDecode(response.body);

        final String imageUrl =
            jsonResponse['secure_url']
                    ?.toString() ??
                '';

        if (imageUrl.isEmpty) {
          throw Exception(
            'Cloudinary image URL not found.',
          );
        }

        // Screen par image show
        profileImageUrl.value = imageUrl;

        // Firestore mein URL save
        await saveImageUrlToFirestore(
          imageUrl,
        );

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
          'Cloudinary upload failed. Status: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Image upload failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ============================================================
  // SAVE CLOUDINARY IMAGE URL TO FIRESTORE
  // ============================================================

  Future<void> saveImageUrlToFirestore(
      String imageUrl) async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar(
        'Error',
        'User is not logged in.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'profileImage': imageUrl,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      // Firebase account se logout
      await FirebaseAuth.instance.signOut();

      // Login screen par wapas
      Get.offAllNamed('/login');
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Logout Error',
        e.message ?? 'Unable to logout.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Logout Error',
        'Unable to logout. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ============================================================
  // CLEAR PROFILE DATA
  // ============================================================

  void clearProfileData() {
    nameController.clear();
    addressController.clear();
    email.value = '';
    profileImageUrl.value = '';
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