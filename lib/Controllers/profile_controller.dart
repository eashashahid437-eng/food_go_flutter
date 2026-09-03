import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final RxString email = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingImage = false.obs;

  final ImagePicker _picker = ImagePicker();

  final String cloudinaryCloudName = 'eyncqf0n';
  final String cloudinaryUploadPreset = 'ml_default';

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        email.value = '';
        nameController.clear();
        addressController.clear();
        profileImageUrl.value = '';
        return;
      }

      email.value = user.email ?? '';

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> data =
            userDoc.data() as Map<String, dynamic>;

        nameController.text = data['name']?.toString() ?? '';
        addressController.text = data['address']?.toString() ?? '';
        profileImageUrl.value = data['profileImage']?.toString() ?? '';
      } else {
        nameController.text = user.displayName ?? '';
        addressController.clear();
        profileImageUrl.value = '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to load profile data.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUserData() async {
    try {
      isSaving.value = true;

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar(
          'Error',
          'User is not logged in.',
          backgroundColor: Colors.white,
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': nameController.text.trim(),
        'email': user.email ?? email.value,
        'address': addressController.text.trim(),
        'profileImage': profileImageUrl.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      email.value = user.email ?? '';

      Get.snackbar(
        'Success',
        'Profile saved successfully.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to save profile data.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedImage == null) {
        return;
      }

      isUploadingImage.value = true;

      final File imageFile = File(pickedImage.path);

      final Uri uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        final String imageUrl = jsonResponse['secure_url']?.toString() ?? '';

        if (imageUrl.isEmpty) {
          throw Exception('Cloudinary image URL not found.');
        }

        profileImageUrl.value = imageUrl;

        await saveImageUrlToFirestore(imageUrl);

        Get.snackbar(
          'Success',
          'Profile picture uploaded successfully.',
          backgroundColor: Colors.white,
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Upload Error',
          'Cloudinary upload failed. Status: ${response.statusCode}',
          backgroundColor: Colors.white,
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Image upload failed: $e',
        backgroundColor: Colors.white,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> saveImageUrlToFirestore(String imageUrl) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar(
        'Error',
        'User is not logged in.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'profileImage': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  Future<void> logout() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      // 1. Agar user logged in hai, toh Admin Panel se uski chat history delete karein
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection("chats")
            .doc(currentUser.uid)
            .delete();
      }

      // 2. Google Session Clear
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // 3. Facebook Session Clear
      await FacebookAuth.instance.logOut();

      // 4. Firebase Auth Sign Out
      await FirebaseAuth.instance.signOut();

      // 5. Local Profile Data Clear
      clearProfileData();

      // 6. Navigate to Login Screen
      Get.offAllNamed('/login');
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Logout Error',
        e.message ?? 'Unable to logout.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Logout Error',
        'Unable to logout. Please try again.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
// Future<void> logout() async {
//   try {
//     // 1. Google Account Session Clear
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//     if (await googleSignIn.isSignedIn()) {
//       await googleSignIn.signOut();
//     }

//     // 2. Facebook Account Session Clear
//     await FacebookAuth.instance.logOut();

//     // 3. Firebase Auth Session Clear
//     await FirebaseAuth.instance.signOut();

//     // 4. Local App Data Clear
//     clearProfileData();

//     // 5. Navigate to Login
//     Get.offAllNamed('/login');
//   } on FirebaseAuthException catch (e) {
//     Get.snackbar(
//       'Logout Error',
//       e.message ?? 'Unable to logout.',
//       backgroundColor: Colors.white,
//       colorText: Colors.black,
//       snackPosition: SnackPosition.TOP,
//     );
//   } catch (e) {
//     Get.snackbar(
//       'Logout Error',
//       'Unable to logout. Please try again.',
//       backgroundColor: Colors.white,
//       colorText: Colors.black,
//       snackPosition: SnackPosition.TOP,
//     );
//   }
// }
  // Future<void> logout() async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     await FacebookAuth.instance.logOut();
  //     clearProfileData();
  //     Get.offAllNamed('/login');
  //   } on FirebaseAuthException catch (e) {
  //     Get.snackbar(
  //       'Logout Error',
  //       e.message ?? 'Unable to logout.',
  //       backgroundColor: Colors.white,
  //       colorText: Colors.black,
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       'Logout Error',
  //       'Unable to logout. Please try again.',
  //       backgroundColor: Colors.white,
  //       colorText: Colors.black,
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   }
  // }

  void clearProfileData() {
    nameController.clear();
    addressController.clear();
    email.value = '';
    profileImageUrl.value = '';
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    super.onClose();
  }
}

// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class ProfileController extends GetxController {
//   final TextEditingController nameController = TextEditingController();

//   final TextEditingController addressController = TextEditingController();

//   final RxString email = ''.obs;

//   final RxString profileImageUrl = ''.obs;

//   final RxBool isLoading = true.obs;

//   final RxBool isSaving = false.obs;

//   final RxBool isUploadingImage = false.obs;

//   final ImagePicker _picker = ImagePicker();

//   final String cloudinaryCloudName = 'eyncqf0n';

//   final String cloudinaryUploadPreset = 'ml_default';

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUserData();
//   }

//   User? get currentUser {
//     return FirebaseAuth.instance.currentUser;
//   }

//   Future<void> fetchUserData() async {
//     try {
//       isLoading.value = true;

//       final User? user = FirebaseAuth.instance.currentUser;

//       if (user == null) {
//         email.value = '';
//         nameController.clear();
//         addressController.clear();
//         profileImageUrl.value = '';
//         return;
//       }

//       email.value = user.email ?? '';

//       final DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();

//       if (userDoc.exists && userDoc.data() != null) {
//         final Map<String, dynamic> data =
//             userDoc.data() as Map<String, dynamic>;

//         nameController.text = data['name']?.toString() ?? '';

//         addressController.text = data['address']?.toString() ?? '';

//         profileImageUrl.value = data['profileImage']?.toString() ?? '';
//       } else {
//         nameController.text = user.displayName ?? '';

//         addressController.clear();

//         profileImageUrl.value = '';
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Unable to load profile data.',
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> saveUserData() async {
//     try {
//       isSaving.value = true;

//       final User? user = FirebaseAuth.instance.currentUser;

//       if (user == null) {
//         Get.snackbar(
//           'Error',
//           'User is not logged in.',
//           backgroundColor: Colors.white,
//           colorText: Colors.black,
//           snackPosition: SnackPosition.TOP,
//         );

//         return;
//       }

//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'uid': user.uid,
//         'name': nameController.text.trim(),
//         'email': user.email ?? email.value,
//         'address': addressController.text.trim(),
//         'profileImage': profileImageUrl.value,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       email.value = user.email ?? '';

//       Get.snackbar(
//         'Success',
//         'Profile saved successfully.',
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//         snackPosition: SnackPosition.TOP,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Unable to save profile data.',
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       isSaving.value = false;
//     }
//   }

//   Future<void> pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedImage = await _picker.pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 1200,
//       );

//       if (pickedImage == null) {
//         return;
//       }

//       isUploadingImage.value = true;

//       final File imageFile = File(pickedImage.path);

//       final Uri uri = Uri.parse(
//         'https://api.cloudinary.com/v1_1/'
//         '$cloudinaryCloudName/image/upload',
//       );

//       final http.MultipartRequest request = http.MultipartRequest('POST', uri);

//       request.fields['upload_preset'] = cloudinaryUploadPreset;

//       request.files.add(
//         await http.MultipartFile.fromPath('file', imageFile.path),
//       );

//       final http.StreamedResponse streamedResponse = await request.send();

//       final http.Response response = await http.Response.fromStream(
//         streamedResponse,
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

//         final String imageUrl = jsonResponse['secure_url']?.toString() ?? '';

//         if (imageUrl.isEmpty) {
//           throw Exception('Cloudinary image URL not found.');
//         }

//         profileImageUrl.value = imageUrl;

//         await saveImageUrlToFirestore(imageUrl);

//         Get.snackbar(
//           'Success',
//           'Profile picture uploaded successfully.',
//           backgroundColor: Colors.white,
//           colorText: Colors.black,
//           snackPosition: SnackPosition.TOP,
//         );
//       } else {
//         Get.snackbar(
//           'Upload Error',
//           'Cloudinary upload failed. Status: ${response.statusCode}',
//           backgroundColor: Colors.white,
//           colorText: Colors.black,
//           snackPosition: SnackPosition.TOP,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Image upload failed: $e',
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//         snackPosition: SnackPosition.TOP,
//       );
//     } finally {
//       isUploadingImage.value = false;
//     }
//   }

//   Future<void> saveImageUrlToFirestore(String imageUrl) async {
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       Get.snackbar(
//         'Error',
//         'User is not logged in.',
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//       );

//       return;
//     }

//     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//       'profileImage': imageUrl,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<void> logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       Get.offAllNamed('/login');
//     } on FirebaseAuthException catch (e) {
//       Get.snackbar(
//         'Logout Error',
//         e.message ?? 'Unable to logout.',
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//         snackPosition: SnackPosition.TOP,
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Logout Error',
//         'Unable to logout. Please try again.',
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//         snackPosition: SnackPosition.TOP,
//       );
//     }
//   }

//   void clearProfileData() {
//     nameController.clear();
//     addressController.clear();
//     email.value = '';
//     profileImageUrl.value = '';
//   }

//   @override
//   void onClose() {
//     nameController.dispose();
//     addressController.dispose();

//     super.onClose();
//   }
// }
