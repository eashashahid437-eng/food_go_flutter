
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final String cloudinaryCloudName = "eyncqf0n";
  final String cloudinaryUploadPreset = "ml_default";

  String email = "Loading...";
  String profileImageUrl = "";

  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ============================================================
  // FETCH USER DATA
  // ============================================================

  Future<void> _fetchUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          email = "No user logged in";
        });

        return;
      }

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['name'] ?? '';
          email = currentUser.email ?? 'No Email';
          _addressController.text = data['address'] ?? '';
          profileImageUrl = data['profileImage'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          _nameController.text =
              currentUser.displayName ?? 'Admin User';
          email = currentUser.email ?? '';
          _addressController.text = '';
          profileImageUrl = '';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        "Error",
        "Failed to load profile:\n$e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ============================================================
  // SAVE USER DATA
  // ============================================================

  Future<bool> _saveUserData() async {
    if (isSaving) return false;

    setState(() {
      isSaving = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User is not logged in.");
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set(
        {
          'name': _nameController.text.trim(),
          'email': email,
          'address': _addressController.text.trim(),
          'profileImage': profileImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return true;

      Get.snackbar(
        "Success",
        "Profile saved successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      if (!mounted) return false;

      Get.snackbar(
        "Error",
        "Failed to save profile:\n$e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      return false;
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // PICK IMAGE + UPLOAD TO CLOUDINARY
  // ============================================================

  Future<void> _pickAndUploadImage() async {
    if (isUploadingImage) return;

    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        isUploadingImage = true;
      });

      final File imageFile = File(image.path);

      // Check file exists
      if (!await imageFile.exists()) {
        throw Exception("Selected image file does not exist.");
      }

      // Cloudinary upload URL
      final Uri uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload",
      );

      debugPrint("========================================");
      debugPrint("CLOUDINARY UPLOAD STARTED");
      debugPrint("Cloud Name: $cloudinaryCloudName");
      debugPrint("Upload Preset: $cloudinaryUploadPreset");
      debugPrint("Image Path: ${imageFile.path}");
      debugPrint("========================================");

      // Create multipart request
      final http.MultipartRequest request =
          http.MultipartRequest('POST', uri);

      // Cloudinary unsigned upload preset
      request.fields['upload_preset'] = cloudinaryUploadPreset;

      // Add image
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Send request
      final http.StreamedResponse streamedResponse =
          await request.send();

      // Convert response
      final http.Response response =
          await http.Response.fromStream(streamedResponse);

      debugPrint("Cloudinary Status Code: ${response.statusCode}");
      debugPrint("Cloudinary Response: ${response.body}");

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final dynamic decodedResponse =
            jsonDecode(response.body);

        if (decodedResponse is! Map<String, dynamic>) {
          throw Exception(
            "Invalid response received from Cloudinary.",
          );
        }

        final String? uploadedImageUrl =
            decodedResponse['secure_url']?.toString();

        if (uploadedImageUrl == null ||
            uploadedImageUrl.isEmpty) {
          throw Exception(
            "Cloudinary did not return secure_url.",
          );
        }

        debugPrint("Uploaded Image URL:");
        debugPrint(uploadedImageUrl);

        if (!mounted) return;

        // Update UI
        setState(() {
          profileImageUrl = uploadedImageUrl;
        });

        // Save URL to Firestore
        final bool saved = await _saveProfileImageToFirestore(
          uploadedImageUrl,
        );

        if (!mounted) return;

        if (saved) {
          Get.snackbar(
            "Success",
            "Profile picture updated successfully!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }

      // ========================================================
      // ERROR
      // ========================================================

      else {
        String errorMessage =
            "Cloudinary upload failed.";

        try {
          final dynamic errorJson =
              jsonDecode(response.body);

          if (errorJson is Map<String, dynamic>) {
            final dynamic error = errorJson['error'];

            if (error is Map<String, dynamic>) {
              errorMessage =
                  error['message']?.toString() ??
                      errorMessage;
            } else if (error != null) {
              errorMessage = error.toString();
            }
          }
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        debugPrint(
          "CLOUDINARY ERROR: $errorMessage",
        );

        if (!mounted) return;

        Get.snackbar(
          "Cloudinary Error",
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
      }
    } catch (e) {
      debugPrint("PROFILE IMAGE ERROR: $e");

      if (!mounted) return;

      Get.snackbar(
        "Upload Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
      }
    }
  }

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
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : Column(
              children: [
                // ==================================================
                // HEADER + PROFILE IMAGE
                // ==================================================

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 180,
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
                    ),

                    const Positioned(
                      top: 40,
                      right: 20,
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),

                    // PROFILE IMAGE
                    Positioned(
                      bottom: -60,
                      left:
                          MediaQuery.of(context).size.width / 2 -
                              70,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2),
                                  blurRadius: 10,
                                  offset:
                                      const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor:
                                    Colors.grey[200],

                                // SHOW CLOUDINARY IMAGE
                                backgroundImage:
                                    profileImageUrl
                                            .isNotEmpty
                                        ? NetworkImage(
                                            profileImageUrl,
                                          )
                                        : const AssetImage(
                                                'assets/images/admin_avatar.png',
                                              )
                                            as ImageProvider,

                                onBackgroundImageError:
                                    profileImageUrl
                                            .isNotEmpty
                                        ? (_, __) {
                                            debugPrint(
                                              "Failed to load profile image:",
                                            );
                                            debugPrint(
                                              profileImageUrl,
                                            );
                                          }
                                        : null,
                              ),
                            ),
                          ),

                          // CAMERA BUTTON
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: isUploadingImage
                                  ? null
                                  : _pickAndUploadImage,
                              borderRadius:
                                  BorderRadius.circular(30),
                              child: Container(
                                padding:
                                    const EdgeInsets.all(8),
                                decoration:
                                    const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF00C0EF),
                                ),
                                child: isUploadingImage
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 80),

                // ==================================================
                // PROFILE DETAILS
                // ==================================================

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildEditableField(
                          "Name",
                          _nameController,
                        ),

                        const SizedBox(height: 20),

                        _buildReadOnlyField(
                          "Email",
                          email,
                        ),

                        const SizedBox(height: 20),

                        _buildEditableField(
                          "Delivery address",
                          _addressController,
                        ),

                        const SizedBox(height: 20),

                        _buildReadOnlyField(
                          "Password",
                          "●●●●●●●●●",
                        ),

                        const SizedBox(height: 30),

                        const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),

                        const SizedBox(height: 20),

                        _buildNavigationItem(
                          "Payment Details",
                          () {},
                        ),

                        const SizedBox(height: 15),

                        _buildNavigationItem(
                          "Order history",
                          () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // ACTION BUTTONS
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(25),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              isSaving || isUploadingImage
                                  ? null
                                  : _saveUserData,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFE91E63),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.save,
                                  size: 18,
                                ),
                          label: Text(
                            isSaving
                                ? "Saving..."
                                : "Save Profile",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              isUploadingImage
                                  ? null
                                  : _logout,
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor:
                                Colors.redAccent,
                            side: const BorderSide(
                              color: Colors.redAccent,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.logout,
                            size: 18,
                          ),
                          label: const Text(
                            "Log out",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
  }

  // ============================================================
  // EDITABLE FIELD
  // ============================================================

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // READ ONLY FIELD
  // ============================================================

  Widget _buildReadOnlyField(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius:
                BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[300]!,
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _buildNavigationItem(
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}




// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:food_go/Auth/Login_Screen.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PersonScreen extends StatefulWidget {
//   const PersonScreen({super.key});

//   @override
//   State<PersonScreen> createState() => _personScreenState();
// }

// class _personScreenState extends State<PersonScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   String email = "Loading...";
//   String profileImageUrl = "";
//   bool isLoading = true;
//   bool isSaving = false;
//   bool isUploadingImage = false;

//   final ImagePicker _picker = ImagePicker();
//   final String cloudinaryCloudName = "eyncqf0n"; 
//   final String cloudinaryUploadPreset = "ml_default";

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   void _fetchUserData() async {
//     try {
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser != null) {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser.uid)
//             .get();

//         if (userDoc.exists && userDoc.data() != null) {
//           var data = userDoc.data() as Map<String, dynamic>;
//           setState(() {
//             _nameController.text = data['name'] ?? '';
//             email = currentUser.email ?? 'No Email';
//             _addressController.text = data['address'] ?? '';
//             profileImageUrl = data['profileImage'] ?? '';
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             _nameController.text = currentUser.displayName ?? 'Admin User';
//             email = currentUser.email ?? '';
//             _addressController.text = '';
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       Get.snackbar("Error", "Failed to load profile: $e",
//           backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }

//   Future<void> _saveUserData() async {
//     setState(() => isSaving = true);
//     try {
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser.uid)
//             .set({
//           'name': _nameController.text.trim(),
//           'email': email,
//           'address': _addressController.text.trim(),
//           'profileImage': profileImageUrl,
//           'updatedAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));

//         Get.snackbar("Success", "Profile saved successfully!",
//             backgroundColor: Colors.green, colorText: Colors.white);
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Failed to save: $e",
//           backgroundColor: Colors.red, colorText: Colors.white);
//     } finally {
//       setState(() => isSaving = false);
//     }
//   }

//   // Gallery se image select karke Cloudinary par upload karne ka function
//   Future<void> _pickAndUploadImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image == null) return;

//       setState(() {
//         isUploadingImage = true;
//       });

//       File imageFile = File(image.path);
//       final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload");

//       var request = http.MultipartRequest('POST', uri)
//         ..fields['upload_preset'] = cloudinaryUploadPreset
//         ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         var jsonResponse = jsonDecode(response.body);
//         String uploadedImageUrl = jsonResponse['secure_url'];

//         setState(() {
//           profileImageUrl = uploadedImageUrl;
//           isUploadingImage = false;
//         });
//         _saveUserData();

//         Get.snackbar("Success", "Profile picture updated successfully!",
//             backgroundColor: Colors.white, colorText: Colors.black);
//       } else {
//         setState(() {
//           isUploadingImage = false;
//         });
//         Get.snackbar("Error", "Failed to upload image to Cloudinary",
//             backgroundColor: Colors.white, colorText: Colors.black);
//       }
//     } catch (e) {
//       setState(() {
//         isUploadingImage = false;
//       });
//       Get.snackbar("Error", "Something went wrong: $e",
//           backgroundColor: Colors.white, colorText: Colors.black);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.red))
//           : Column(
//               children: [
              
//                 Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Container(
//                       height: 180,
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Color(0xFFFF5722),
//                             Color(0xFFE91E63),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const Positioned(
//                       top: 40,
//                       right: 20,
//                       child: Icon(Icons.settings, color: Colors.white),
//                     ),
//                     Positioned(
//                       bottom: -60,
//                       left: MediaQuery.of(context).size.width / 2 - 70,
//                       child: Stack(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: CircleAvatar(
//                               radius: 70,
//                               backgroundColor: Colors.white,
//                               child: CircleAvatar(
//                                 radius: 65,
//                                 backgroundColor: Colors.grey[200],
//                                 backgroundImage: profileImageUrl.isNotEmpty
//                                     ? NetworkImage(profileImageUrl) as ImageProvider
//                                     : const AssetImage('assets/images/admin_avatar.png'),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: InkWell(
//                               onTap: isUploadingImage ? null : _pickAndUploadImage,
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: const BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Color(0xFF00C0EF),
//                                 ),
//                                 child: isUploadingImage
//                                     ? const SizedBox(
//                                         width: 18,
//                                         height: 18,
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white, strokeWidth: 2),
//                                       )
//                                     : const Icon(Icons.camera_alt,
//                                         color: Colors.white, size: 18),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 80),

//                 // --- Profile Details (Editable Fields) ---
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildEditableField("Name", _nameController),
//                         const SizedBox(height: 20),
//                         _buildReadOnlyField("Email", email),
//                         const SizedBox(height: 20),
//                         _buildEditableField("Delivery address", _addressController),
//                         const SizedBox(height: 20),
//                         _buildReadOnlyField("Password", "●●●●●●●●●"),
//                         const SizedBox(height: 30),
//                         const Divider(color: Colors.grey, thickness: 0.5),
//                         const SizedBox(height: 20),
//                         _buildNavigationItem("Payment Details", () {}),
//                         const SizedBox(height: 15),
//                         _buildNavigationItem("Order history", () {}),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // --- Action Buttons ---
//                 Container(
//                   padding: const EdgeInsets.all(25),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: isSaving ? null : _saveUserData,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFE91E63),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                           ),
//                           icon: isSaving 
//                               ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                               : const Icon(Icons.save, size: 18),
//                           label: Text(isSaving ? "Saving..." : "Save Profile",
//                               style: const TextStyle(fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                       const SizedBox(width: 15),
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () async {
//                             // await FirebaseAuth.instance.signOut();
//                             // Navigator.of(context).pop();
//                             FirebaseAuth.instance.signOut().then((value) {
//   Get.offAll(() => LoginScreen());
// });
//                           },
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.redAccent,
//                             side: const BorderSide(color: Colors.redAccent),
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8)),
//                           ),
//                           icon: const Icon(Icons.logout, size: 18),
//                           label: const Text("Log out",
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
//   Widget _buildEditableField(String label, TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
//         const SizedBox(height: 5),
//         TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.grey[100],
//             contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildReadOnlyField(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
//         const SizedBox(height: 5),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNavigationItem(String title, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(title,
//                 style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w500)),
//             Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
//           ],
//         ),
//       ),
//     );
//   }
// }
