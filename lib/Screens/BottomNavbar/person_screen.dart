import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Controllers/profile_controller.dart';
import 'package:food_go/Screens/BottomNavbar/paymentscreen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// IMPORTANT:
// In dono files ke import paths apni existing files ke according change karna.
// Example:
// import 'package:food_go/Screens/orderhistory.dart';
// import 'package:food_go/Screens/paymentdetails.dart';

import 'orderhistory.dart';

class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller =
        Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF5722),
            ),
          );
        }

        final User? user =
            FirebaseAuth.instance.currentUser;

        return SingleChildScrollView(
          child: Column(
            children: [

              // ================= HEADER =================

              Container(
                height: 210,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF5722),
                      Color(0xFFE91E63),
                    ],
                  ),
                ),

                child: Center(
                  child: Stack(
                    children: [

                      // PROFILE IMAGE
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(18),

                          child: controller
                                  .profileImageUrl
                                  .value
                                  .isNotEmpty
                              ? Image.network(
                                  controller
                                      .profileImageUrl
                                      .value,
                                  fit: BoxFit.cover,

                                  errorBuilder:
                                      (_, __, ___) {
                                    return const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                        ),
                      ),

                      // ================= CAMERA =================

                      Positioned(
                        right: 0,
                        bottom: 0,

                        child: GestureDetector(
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
                            width: 38,
                            height: 38,

                            decoration:
                                const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),

                            child: controller
                                    .isUploadingImage
                                    .value
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(10),
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= FORM =================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Column(
                  children: [

                    // NAME
                    _field(
                      'Name',
                      controller.nameController,
                      Icons.person,
                    ),

                    const SizedBox(height: 15),

                    // EMAIL
                    _readOnly(
                      'Email',
                      user?.email ??
                          controller.email.value,
                      Icons.email,
                    ),

                    const SizedBox(height: 15),

                    // ADDRESS
                    _field(
                      'Delivery Address',
                      controller.addressController,
                      Icons.location_on,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 15),

                    // PASSWORD
                    _readOnly(
                      'Password',
                      '••••••••',
                      Icons.lock,
                    ),

                    const SizedBox(height: 25),

                    const Divider(),

                    const SizedBox(height: 5),

                    // =================================================
                    // PAYMENT DETAILS
                    // =================================================

                    ListTile(
                      contentPadding:
                          EdgeInsets.zero,

                      leading: const Icon(
                        Icons.payment,
                        color: Color(0xFFFF5722),
                      ),

                      title: const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      ),

                      onTap: () {
                        Get.to(
                          () =>
                              const PaymentDetailsScreen(),
                        );
                      },
                    ),

                    // =================================================
                    // ORDER HISTORY
                    // =================================================

                    ListTile(
                      contentPadding:
                          EdgeInsets.zero,

                      leading: const Icon(
                        Icons.history,
                        color: Color(0xFFFF5722),
                      ),

                      title: const Text(
                        'Order History',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                      ),

                      onTap: () {
                        Get.to(
                          () =>
                              const OrderHistoryScreen(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ================= BUTTONS =================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                color: Colors.white,

                child: Row(
                  children: [

                    // SAVE
                    Expanded(
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            controller
                                    .isSaving
                                    .value
                                ? null
                                : () async {
                                    await controller
                                        .saveUserData();
                                  },

                        icon: controller
                                .isSaving
                                .value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.save,
                              ),

                        label: Text(
                          controller
                                  .isSaving
                                  .value
                              ? 'Saving...'
                              : 'Save Profile',
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black87,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // LOGOUT
                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            controller.logout,

                        icon: const Icon(
                          Icons.logout,
                        ),

                        label:
                            const Text('Log Out'),

                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.redAccent,
                          side:
                              const BorderSide(
                            color:
                                Colors.redAccent,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // CAMERA + GALLERY BOTTOM SHEET
  // ============================================================

  void _showImageOptions(
    BuildContext context,
    ProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [

              const Padding(
                padding:
                    EdgeInsets.all(18),

                child: Center(
                  child: Text(
                    'Select Profile Picture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // CAMERA
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFFFF5722),
                ),

                title:
                    const Text('Camera'),

                onTap: () {
                  Navigator.pop(context);

                  controller.pickImage(
                    ImageSource.camera,
                  );
                },
              ),

              // GALLERY
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFFF5722),
                ),

                title:
                    const Text('Gallery'),

                onTap: () {
                  Navigator.pop(context);

                  controller.pickImage(
                    ImageSource.gallery,
                  );
                },
              ),

              // CANCEL
              ListTile(
                leading:
                    const Icon(Icons.close),

                title:
                    const Text('Cancel'),

                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // EDITABLE FIELD
  // ============================================================

  Widget _field(
    String title,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 5),

        TextField(
          controller: controller,
          maxLines: maxLines,

          decoration:
              InputDecoration(
            prefixIcon:
                Icon(icon),

            filled: true,

            fillColor:
                Colors.grey[200],

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),

              borderSide:
                  BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // READ ONLY FIELD
  // ============================================================

  Widget _readOnly(
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 5),

        Container(
          width: double.infinity,

          padding:
              const EdgeInsets.all(15),

          decoration:
              BoxDecoration(
            color: Colors.grey[200],

            borderRadius:
                BorderRadius.circular(10),
          ),

          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  value.isEmpty
                      ? 'Not available'
                      : value,

                  style:
                      const TextStyle(
                    color:
                        Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
