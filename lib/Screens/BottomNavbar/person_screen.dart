import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/profile_controller.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:food_go/Screens/BottomNavbar/paymentscreen.dart';
import 'package:food_go/Screens/settingscreen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'orderhistory.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final bool isDark = Get.isDarkMode;
    final Size screenSize = MediaQuery.sizeOf(context);

    final Color mainBgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final Color cardBgColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: mainBgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.darkpink,
              ),
            );
          }

          final User? user = FirebaseAuth.instance.currentUser;

          String profileName = controller.nameController.text.trim();
          if (profileName.isEmpty) {
            profileName = user?.displayName?.trim() ?? '';
          }
          if (profileName.isEmpty) {
            profileName = 'Not available';
          }

          final String profileEmail = user?.email?.trim().isNotEmpty == true
              ? user!.email!.trim()
              : controller.email.value;

          final String firebasePhotoUrl = user?.photoURL?.trim() ?? '';
          final String controllerPhotoUrl = controller.profileImageUrl.value.trim();
          final String profilePhotoUrl = controllerPhotoUrl.isNotEmpty
              ? controllerPhotoUrl
              : firebasePhotoUrl;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: (screenSize.height < 700 ? 180 : 200) +
                      (screenSize.height < 700 ? 110 : 125) / 2,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: screenSize.height < 700 ? 180 : 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.darkpink,
                        ),
                      ),
                      Positioned(
                        left: -60,
                        top: 5,
                        child: Opacity(
                          opacity: 0.65,
                          child: Image.asset(
                            'assets/images/profile burger.png',
                            width: 190,
                            height: 190,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -60,
                        top: 5,
                        child: Opacity(
                          opacity: 0.65,
                          child: Image.asset(
                            'assets/images/profile burger 2.png',
                            width: 190,
                            height: 190,
                          ),
                        ),
                      ),
                      Container(
                        height: screenSize.height < 700 ? 180 : 200,
                        width: double.infinity,
                        color: AppColors.darkpink.withOpacity(0.35),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: screenSize.height < 700 ? 165 : 185,
                        bottom: -1000,
                        child: Container(
                          decoration: BoxDecoration(
                            color: mainBgColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 15,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => Get.offAll(() => BottomNavbar()),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => Get.to(() => const SettingsScreen()),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: controller.isUploadingImage.value
                                ? null
                                : () => _showImageOptions(
                                      context,
                                      controller,
                                      isDark,
                                    ),
                            child: Container(
                              width: screenSize.height < 700 ? 110 : 125,
                              height: screenSize.height < 700 ? 110 : 125,
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: AppColors.darkpink,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.5)
                                        : Colors.black12,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: profilePhotoUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: profilePhotoUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.darkpink,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: cardBgColor,
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: cardBgColor,
                                        child: controller.isUploadingImage.value
                                            ? const Padding(
                                                padding: EdgeInsets.all(30),
                                                child: CircularProgressIndicator(
                                                  color: AppColors.darkpink,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _field(
                        'Name',
                        controller.nameController,
                        Icons.person_outline,
                        isDark,
                        compact: true,
                        initialValue: profileName,
                      ),
                      const SizedBox(height: 12),
                      _readOnly(
                        'Email',
                        profileEmail,
                        Icons.email_outlined,
                        isDark,
                        compact: true,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        'Delivery Address',
                        controller.addressController,
                        Icons.location_on_outlined,
                        isDark,
                        maxLines: 1,
                        compact: true,
                      ),
                      const SizedBox(height: 16),
                      Divider(
                        color: isDark
                            ? AppColors.surfaceDark
                            : Colors.grey.shade300,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 4),
                      _figmaStyleAction(
                        title: 'Payment Details',
                        isDark: isDark,
                        onTap: () => Get.to(() => const PaymentDetailsScreen()),
                      ),
                      _figmaStyleAction(
                        title: 'Order history',
                        isDark: isDark,
                        onTap: () => Get.to(() => const OrderHistoryScreen()),
                      ),
                      Divider(
                        color: isDark
                            ? AppColors.surfaceDark
                            : Colors.grey.shade300,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 18),
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
                                  backgroundColor: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.black87,
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
                                  _showLogoutDialog(
                                    context,
                                    controller,
                                    isDark,
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  size: 18,
                                ),
                                label: const Text('Log Out'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.darkpink,
                                  side: const BorderSide(
                                    color: AppColors.darkpink,
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
        }),
      ),
    );
  }

  static Widget _figmaStyleAction({
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark
                    ? AppColors.lightwhite
                    : AppColors.textPrimaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _field(
    String title,
    TextEditingController controller,
    IconData icon,
    bool isDark, {
    int maxLines = 1,
    bool compact = false,
    String? initialValue,
  }) {
    if (initialValue != null &&
        initialValue.isNotEmpty &&
        controller.text.trim().isEmpty) {
      controller.text = initialValue;
    }

    final Color labelColor =
        isDark ? Colors.grey.shade300 : AppColors.textPrimaryLight;
    final Color inputBgColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final Color textColor =
        isDark ? AppColors.lightwhite : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
              size: 22,
            ),
            filled: true,
            fillColor: inputBgColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 10 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.surfaceDark
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.surfaceDark
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.darkpink,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _readOnly(
    String title,
    String value,
    IconData icon,
    bool isDark, {
    bool compact = false,
  }) {
    final Color labelColor =
        isDark ? Colors.grey.shade300 : AppColors.textPrimaryLight;
    final Color inputBgColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final Color textColor =
        isDark ? AppColors.lightwhite : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: compact ? 11 : 14,
          ),
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.surfaceDark
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDark ? Colors.grey.shade400 : Colors.grey[500],
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value.isEmpty ? 'Not available' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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

  static void _showImageOptions(
    BuildContext context,
    ProfileController controller,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'Change Profile Picture',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.lightwhite : Colors.black,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.darkpink.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.darkpink,
                    ),
                  ),
                  title: Text(
                    'Take Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.lightwhite : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Use your camera',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.darkpink.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.darkpink,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.lightwhite : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Select an existing photo',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                  leading: const Icon(Icons.close, color: Colors.grey),
                  title: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showLogoutDialog(
    BuildContext context,
    ProfileController controller,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.lightwhite : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkpink,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

