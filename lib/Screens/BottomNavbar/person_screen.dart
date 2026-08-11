
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:food_go/Controllers/profile_controller.dart';
import 'package:food_go/Screens/BottomNavbar/paymentscreen.dart';
import 'package:food_go/Screens/settingscreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'orderhistory.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  // =============================================================
  // COLORS
  // =============================================================

  static const Color redColor = Color(0xFFFF1744);
  static const Color pinkColor = Color(0xFFFF006E);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color textColor = Color(0xFF252525);

  // ============================================================
  // SAVE PROFILE IMAGE URL TO FIRESTORE
  // ============================================================

  Future<bool> _saveProfileImageToFirestore(
    String imageUrl,
  ) async {
    try {
      final User? currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User is not logged in.");
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set(
        {
          'profileImage': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      debugPrint(
        "Profile image URL saved to Firestore.",
      );

      return true;
    } catch (e) {
      debugPrint(
        "Failed to save image URL to Firestore: $e",
      );

      if (mounted) {
        Get.snackbar(
          "Firestore Error",
          "Image uploaded but could not be saved:\n$e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }

      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Get.offAll(
        () => const LoginScreen(),
      );
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        "Error",
        "Logout failed:\n$e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ProfileController controller =
        Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: redColor,
              ),
            );
          }

          final User? user = FirebaseAuth.instance.currentUser;

          return LayoutBuilder(
            builder: (context, constraints) {
              final double screenHeight = constraints.maxHeight;
              final double headerHeight = screenHeight < 700 ? 180 : 200;
              final double profileSize = screenHeight < 700 ? 110 : 125;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // =================================================
                    // HEADER
                    // =================================================
                    SizedBox(
                      height: headerHeight + (profileSize / 2),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // =============================================
                          // RED HEADER
                          // =============================================
                          Container(
                            height: headerHeight,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  redColor,
                                  pinkColor,
                                ],
                              ),
                            ),
                          ),

                          // =============================================
                          // SETTINGS BUTTON (Transparent Background)
                          // =============================================
                          Positioned(
                            top: 15,
                            right: 20,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {
                                  Get.to(
                                    () => const SettingsScreen(),
                                  );
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // =============================================
                          // PROFILE IMAGE (Tap to change, NO camera icon)
                          // =============================================
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: controller.isUploadingImage.value
                                    ? null
                                    : () {
                                        _showImageOptions(context, controller);
                                      },
                                child: Container(
                                  width: profileSize,
                                  height: profileSize,
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: redColor,
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: controller
                                            .profileImageUrl
                                            .value
                                            .isNotEmpty
                                        ? Image.network(
                                            controller.profileImageUrl.value,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: redColor,
                                                  strokeWidth: 2.5,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[100],
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[100],
                                            child: controller
                                                    .isUploadingImage.value
                                                ? const Padding(
                                                    padding: EdgeInsets.all(30),
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: redColor,
                                                      strokeWidth: 2.5,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // PROFILE CONTENT
                    // =================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),

                          // ===========================================
                          // NAME
                          // ===========================================
                          _field(
                            'Name',
                            controller.nameController,
                            Icons.person_outline,
                            compact: true,
                          ),

                          const SizedBox(height: 10),

                          // ===========================================
                          // EMAIL
                          // ===========================================
                          _readOnly(
                            'Email',
                            user?.email ?? controller.email.value,
                            Icons.email_outlined,
                            compact: true,
                          ),

                          const SizedBox(height: 10),

                          // ===========================================
                          // DELIVERY ADDRESS
                          // ===========================================
                          _field(
                            'Delivery Address',
                            controller.addressController,
                            Icons.location_on_outlined,
                            maxLines: 1,
                            compact: true,
                          ),

                          const SizedBox(height: 10),

                          // ===========================================
                          // PASSWORD
                          // ===========================================
                          _readOnly(
                            'Password',
                            '••••••••',
                            Icons.lock_outline,
                            compact: true,
                          ),

                          const SizedBox(height: 14),

                          const Divider(
                            color: lightBorder,
                            thickness: 1,
                            height: 1,
                          ),

                          const SizedBox(height: 4),

                          // ===========================================
                          // PAYMENT + ORDER ROWS (Figma Style)
                          // ===========================================
                          _figmaStyleAction(
                            title: 'Payment Details',
                            onTap: () {
                              Get.to(() => const PaymentDetailsScreen());
                            },
                          ),

                          _figmaStyleAction(
                            title: 'Order history',
                            onTap: () {
                              Get.to(() => const OrderHistoryScreen());
                            },
                          ),

                          const Divider(
                            color: lightBorder,
                            thickness: 1,
                            height: 1,
                          ),

                          const SizedBox(height: 14),

                          // ===========================================
                          // SAVE + LOGOUT BUTTONS
                          // ===========================================
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: controller.isSaving.value
                                        ? null
                                        : () async {
                                            await controller.saveUserData();
                                          },
                                    icon: controller.isSaving.value
                                        ? const SizedBox(
                                            width: 17,
                                            height: 17,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                          ),
                                    label: Text(
                                      controller.isSaving.value
                                          ? 'Saving...'
                                          : 'Edit Profile',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _showLogoutDialog(context, controller);
                                    },
                                    icon: const Icon(
                                      Icons.logout,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Log Out',
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: redColor,
                                      side: const BorderSide(
                                        color: redColor,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // =============================================================
  // FIGMA STYLE ROW ACTION (Payment & Order History)
  // =============================================================

  static Widget _figmaStyleAction({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // EDITABLE FIELD
  // =============================================================

  static Widget _field(
    String title,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            color: textColor,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.grey,
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 10 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: lightBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: lightBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: redColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // READ ONLY FIELD
  // =============================================================

  static Widget _readOnly(
    String title,
    String value,
    IconData icon, {
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: compact ? 11 : 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: lightBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[500],
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value.isEmpty ? 'Not available' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // CAMERA + GALLERY OPTIONS (Triggered by touching profile image)
  // =============================================================

  static void _showImageOptions(
    BuildContext context,
    ProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 15,
            ),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Change Profile Picture',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: redColor.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: redColor,
                    ),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Use your camera',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: redColor.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: redColor,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Select an existing photo',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  leading: const Icon(
                    Icons.close,
                    color: Colors.grey,
                  ),
                  title: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // LOGOUT DIALOG
  // =============================================================

  static void _showLogoutDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            child: const Text(
              'Logout',
            ),
          ),
        ],
      ),
    );
  }
}




