import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Controllers/profile_controller.dart';
import 'package:food_go/Screens/BottomNavbar/paymentscreen.dart';
import 'package:food_go/Screens/settingscreen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'orderhistory.dart';

class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key});

  // =============================================================
  // COLORS
  // =============================================================

  static const Color redColor = Color(0xFFFF1744);
  static const Color pinkColor = Color(0xFFFF006E);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color textColor = Color(0xFF252525);

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: redColor,
            ),
          );
        }

        final User? user = FirebaseAuth.instance.currentUser;

        return SingleChildScrollView(
          child: Column(
            children: [
              // =====================================================
              // RED HEADER + WHITE SHEET + PROFILE IMAGE
              // =====================================================

              Stack(
                clipBehavior: Clip.none,
                children: [
                  // =================================================
                  // RED HEADER
                  // =================================================

                  Container(
                    height: 270,
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

                  // =================================================
                  // SETTINGS BUTTON
                  // =================================================

                  Positioned(
                    top: 45,
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
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // WHITE SHEET
                  // =================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 135,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(45),
                          topRight: Radius.circular(45),
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // PROFILE IMAGE
                  // =================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 35,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // =================================================
                          // PROFILE IMAGE CONTAINER
                          // =================================================

                          Container(
                            width: 145,
                            height: 145,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),

                              // THIN BORDER
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),

                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: Offset(0, 7),
                                ),
                              ],
                            ),

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(23),
                              child: controller
                                      .profileImageUrl
                                      .value
                                      .isNotEmpty
                                  ? Image.network(
                                      controller.profileImageUrl.value,
                                      fit: BoxFit.cover,

                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }

                                        return const Center(
                                          child:
                                              CircularProgressIndicator(
                                            color: redColor,
                                          ),
                                        );
                                      },

                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey[100],
                                          child: const Icon(
                                            Icons.person,
                                            size: 65,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[100],
                                      child: const Icon(
                                        Icons.person,
                                        size: 65,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),

                          // =================================================
                          // CAMERA BUTTON
                          // =================================================

                          Positioned(
                            right: -8,
                            bottom: -8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                customBorder: const CircleBorder(),

                                // =================================================
                                // IMPORTANT:
                                // CAMERA BUTTON AB OPTIONS OPEN KAREGA
                                // DIRECT CAMERA NAHI
                                // =================================================

                                onTap: controller
                                        .isUploadingImage
                                        .value
                                    ? null
                                    : () {
                                        _showImageOptions(
                                          context,
                                          controller,
                                        );
                                      },

                                child: Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,

                                    // THIN WHITE BORDER
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),

                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),

                                  child: controller
                                          .isUploadingImage
                                          .value
                                      ? const Padding(
                                          padding: EdgeInsets.all(15),
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 27,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // =====================================================
              // SPACE AFTER HEADER
              // =====================================================

              const SizedBox(height: 20),

              // =====================================================
              // PROFILE INFORMATION
              // =====================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // NAME
                    // =================================================

                    _field(
                      'Name',
                      controller.nameController,
                      Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // EMAIL
                    // =================================================

                    _readOnly(
                      'Email',
                      user?.email ?? controller.email.value,
                      Icons.email_outlined,
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // DELIVERY ADDRESS
                    // =================================================

                    _field(
                      'Delivery Address',
                      controller.addressController,
                      Icons.location_on_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // PASSWORD
                    // =================================================

                    _readOnly(
                      'Password',
                      '••••••••',
                      Icons.lock_outline,
                    ),

                    const SizedBox(height: 28),

                    // =================================================
                    // DIVIDER
                    // =================================================

                    const Divider(
                      color: lightBorder,
                      thickness: 1,
                    ),

                    const SizedBox(height: 8),

                    // =================================================
                    // PAYMENT DETAILS
                    // =================================================

                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: redColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.credit_card_outlined,
                          color: redColor,
                        ),
                      ),

                      title: const Text(
                        'Payment Details',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: const Text(
                        'Manage your payment methods',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),

                      onTap: () {
                        Get.to(
                          () => const PaymentDetailsScreen(),
                        );
                      },
                    ),

                    const Divider(
                      color: lightBorder,
                      thickness: 1,
                    ),

                    // =================================================
                    // ORDER HISTORY
                    // =================================================

                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: redColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: redColor,
                        ),
                      ),

                      title: const Text(
                        'Order History',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: const Text(
                        'View your previous orders',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),

                      onTap: () {
                        Get.to(
                          () => const OrderHistoryScreen(),
                        );
                      },
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),

              // =====================================================
              // SAVE + LOGOUT BUTTONS
              // =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  24,
                  18,
                  24,
                  30,
                ),
                color: Colors.white,

                child: Row(
                  children: [
                    // =================================================
                    // SAVE PROFILE
                    // =================================================

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                await controller.saveUserData();
                              },

                        icon: controller.isSaving.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.edit_outlined,
                                size: 20,
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

                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // =================================================
                    // LOGOUT
                    // =================================================

                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showLogoutDialog(
                            context,
                            controller,
                          );
                        },

                        icon: const Icon(
                          Icons.logout,
                          size: 20,
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

                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,

          style: const TextStyle(
            color: textColor,
            fontSize: 15,
          ),

          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.grey,
            ),

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            // =================================================
            // THIN BORDER
            // =================================================

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(
                color: lightBorder,
                width: 1,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(
                color: lightBorder,
                width: 1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
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
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),

            // =================================================
            // THIN BORDER
            // =================================================

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
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  value.isEmpty ? 'Not available' : value,

                  style: const TextStyle(
                    color: textColor,
                    fontSize: 15,
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
  // CAMERA + GALLERY OPTIONS
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
                // =================================================
                // HANDLE
                // =================================================

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

                // =================================================
                // TITLE
                // =================================================

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

                // =================================================
                // TAKE PHOTO
                // =================================================

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

                    // CAMERA OPEN
                    controller.pickImage(
                      ImageSource.camera,
                    );
                  },
                ),

                // =================================================
                // GALLERY
                // =================================================

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

                    // GALLERY OPEN
                    controller.pickImage(
                      ImageSource.gallery,
                    );
                  },
                ),

                // =================================================
                // CANCEL
                // =================================================

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
