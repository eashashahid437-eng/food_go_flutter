import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/settingScreencontroller.dart';
import 'package:food_go/Screens/BottomNavbar/orderhistory.dart';
import 'package:food_go/Screens/BottomNavbar/paymentscreen.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    final bool isDark = Get.isDarkMode;
    final Size screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.lightwhite : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.055,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          _sectionTitle('Account'),
          _settingTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Manage your profile information',
            onTap: () => Get.back(),
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.location_on_outlined,
            title: 'Delivery Addresses',
            subtitle: 'Manage your delivery locations',
            onTap: () {
              Get.to(() => const AddressesScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.lock_outline,
            title: 'Password & Security',
            subtitle: 'Manage your account security',
            onTap: () {
              Get.to(() => const SecurityScreen());
            },
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _sectionTitle('Food Go'),
          _settingTile(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your saved payment methods',
            onTap: () {
              Get.to(() => const PaymentDetailsScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Food Go Wallet',
            subtitle: 'Balance and wallet transactions',
            onTap: () {
              Get.to(() => const WalletScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.favorite_border,
            title: 'Saved Items',
            subtitle: 'Your favorite food items',
            onTap: () {
              Get.to(() => const SavedItemsScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.receipt_long_outlined,
            title: 'Orders',
            subtitle: 'View your previous orders',
            onTap: () {
              Get.to(() => const OrderHistoryScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.calendar_month_outlined,
            title: 'Bookings',
            subtitle: 'Manage your bookings',
            onTap: () {
              Get.to(() => const BookingsScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.card_giftcard_outlined,
            title: 'Rewards',
            subtitle: 'View your Food Go reward points',
            onTap: () {
              Get.to(() => const RewardsScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.redeem_outlined,
            title: 'Gift Cards',
            subtitle: 'Manage and redeem gift cards',
            onTap: () {
              Get.to(() => const GiftCardsScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.people_outline,
            title: 'Refer Friends',
            subtitle: 'Invite friends and earn rewards',
            onTap: () {
              Get.to(() => const ReferFriendsScreen());
            },
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _sectionTitle('Notifications'),
          Obx(
            () => SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              secondary: const Icon(
                Icons.notifications_none,
                color: Colors.red,
              ),
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              subtitle: const Text(
                'Receive app notifications',
                style: TextStyle(color: Colors.grey),
              ),
              value: controller.notificationsEnabled.value,
              activeColor: Colors.red,
              onChanged: controller.toggleNotifications,
            ),
          ),
          Obx(
            () => SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              secondary: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.red,
              ),
              title: Text(
                'Order Updates',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              subtitle: const Text(
                'Receive updates about your orders',
                style: TextStyle(color: Colors.grey),
              ),
              value: controller.orderNotifications.value,
              activeColor: Colors.red,
              onChanged: controller.notificationsEnabled.value
                  ? controller.toggleOrderNotifications
                  : null,
            ),
          ),
          Obx(
            () => SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              secondary: const Icon(
                Icons.local_offer_outlined,
                color: Colors.red,
              ),
              title: Text(
                'Offers & Promotions',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              subtitle: const Text(
                'Receive special offers and promotions',
                style: TextStyle(color: Colors.grey),
              ),
              value: controller.promotionalNotifications.value,
              activeColor: Colors.red,
              onChanged: controller.notificationsEnabled.value
                  ? controller.togglePromotionalNotifications
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          _sectionTitle('Support'),
          _settingTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with Food Go',
            onTap: () {
              Get.to(() => const HelpSupportScreen());
            },
            isDark: isDark,
          ),
          _settingTile(
            icon: Icons.info_outline,
            title: 'About Food Go',
            subtitle: 'App information and version',
            onTap: () {
              Get.to(() => const AboutScreen());
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    title: Text(
                      'Logout',
                      style: TextStyle(
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
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          Get.back();
                          await controller.logout();
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  static Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.red, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? AppColors.lightwhite : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .collection('addresses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                return Card(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(
                      data['title'] ?? 'Address',
                      style: TextStyle(
                        color: isDark ? AppColors.lightwhite : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      data['address'] ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        controller.deleteAddress(doc.id);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  _addAddressDialog(context, controller, isDark);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add New Address'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addAddressDialog(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Add Address',
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(
                color: isDark ? AppColors.lightwhite : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Address title',
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: 'Home / Work',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextField(
              controller: addressController,
              maxLines: 3,
              style: TextStyle(
                color: isDark ? AppColors.lightwhite : Colors.black,
              ),
              decoration: const InputDecoration(
                labelText: 'Full address',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              controller.addAddress(
                title: titleController.text,
                address: addressController.text,
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final passwordController = TextEditingController();
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Password & Security'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.security, size: 70, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            'Account Security',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.lightwhite : Colors.black,
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(
              color: isDark ? AppColors.lightwhite : Colors.black,
            ),
            decoration: const InputDecoration(
              labelText: 'New Password',
              labelStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              controller.changePassword(passwordController.text.trim());
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Food Go Wallet'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .snapshots(),
        builder: (context, snapshot) {
          double balance = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            balance =
                double.tryParse(data?['walletBalance']?.toString() ?? '0') ?? 0;
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(25),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 35,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Rs. ${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.lightwhite : Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(controller.uid)
                      .collection('walletTransactions')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No wallet transactions yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.payment, color: Colors.white),
                          ),
                          title: Text(
                            data['title'] ?? 'Transaction',
                            style: TextStyle(
                              color: isDark ? AppColors.lightwhite : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            data['type'] ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            'Rs. ${data['amount'] ?? 0}',
                            style: TextStyle(
                              color: isDark ? AppColors.lightwhite : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .collection('savedItems')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No saved items yet.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(15),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(
                    data['name'] ?? 'Food Item',
                    style: TextStyle(
                      color: isDark ? AppColors.lightwhite : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    data['description'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    'Rs. ${data['price'] ?? ''}',
                    style: TextStyle(
                      color: isDark ? AppColors.lightwhite : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Colors.red,
                ),
                title: Text(
                  data['restaurant'] ?? 'Booking',
                  style: TextStyle(
                    color: isDark ? AppColors.lightwhite : Colors.black,
                  ),
                ),
                subtitle: Text(
                  '${data['date'] ?? ''} • ${data['time'] ?? ''}',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  data['status'] ?? 'Pending',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .snapshots(),
        builder: (context, snapshot) {
          int points = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            points =
                int.tryParse(data?['rewardPoints']?.toString() ?? '0') ?? 0;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Reward Points',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$points Points',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.lightwhite : Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GiftCardsScreen extends StatefulWidget {
  const GiftCardsScreen({super.key});

  @override
  State<GiftCardsScreen> createState() => _GiftCardsScreenState();
}

class _GiftCardsScreenState extends State<GiftCardsScreen> {
  final TextEditingController codeController = TextEditingController();
  bool loading = false;

  Future<void> redeemCard() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      Get.snackbar('Error', 'Enter gift card code.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final card = await FirebaseFirestore.instance
          .collection('giftCards')
          .doc(code)
          .get();

      if (!card.exists) {
        Get.snackbar('Invalid Code', 'Gift card does not exist.');
        return;
      }

      final data = card.data()!;

      if (data['used'] == true) {
        Get.snackbar(
          'Unavailable',
          'This gift card has already been used.',
        );
        return;
      }

      final amount = data['amount'] ?? 0;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'walletBalance': FieldValue.increment((amount as num).toDouble()),
      }, SetOptions(merge: true));

      await card.reference.update({
        'used': true,
        'usedBy': uid,
        'usedAt': FieldValue.serverTimestamp(),
      });

      codeController.clear();
      Get.snackbar('Success', 'Gift card redeemed successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Unable to redeem gift card.');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Gift Cards'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.card_giftcard, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              style: TextStyle(
                color: isDark ? AppColors.lightwhite : Colors.black,
              ),
              decoration: const InputDecoration(
                labelText: 'Gift Card Code',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter your code',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.redeem, color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: loading ? null : redeemCard,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Redeem Gift Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReferFriendsScreen extends StatelessWidget {
  const ReferFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final referralCode = user?.uid.substring(0, 8).toUpperCase() ?? 'FOODGO';
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Refer Friends'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'Invite your friends to Food Go',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Share your referral code and earn rewards.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  referralCode,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: isDark ? AppColors.lightwhite : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Get.snackbar('Referral Code', 'Your code is $referralCode');
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Referral Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const SizedBox(height: 15),
          const Icon(Icons.support_agent, size: 75, color: Colors.red),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'How can we help?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.lightwhite : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Card(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.chat, color: Colors.red),
              title: Text(
                'Chat Support',
                style: TextStyle(
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              subtitle: const Text(
                'Talk to Food Go support',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.grey,
              ),
              onTap: () {
                Get.snackbar('Support', 'Support chat will be available soon.');
              },
            ),
          ),
          Card(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: Colors.red,
              ),
              title: Text(
                'Email Support',
                style: TextStyle(
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              subtitle: const Text(
                'support@foodgo.com',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.grey,
              ),
              onTap: () {
                Get.snackbar('Email', 'support@foodgo.com');
              },
            ),
          ),
          Card(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.grey,
              leading: const Icon(
                Icons.help_outline,
                color: Colors.red,
              ),
              title: Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              children: [
                ListTile(
                  title: Text(
                    'How can I place an order?',
                    style: TextStyle(color: isDark ? AppColors.lightwhite : Colors.black),
                  ),
                  subtitle: const Text(
                    'Select your food item, add it to cart and complete checkout.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ListTile(
                  title: Text(
                    'How can I track my order?',
                    style: TextStyle(color: isDark ? AppColors.lightwhite : Colors.black),
                  ),
                  subtitle: const Text(
                    'Open Orders from your profile to see your order status.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ListTile(
                  title: Text(
                    'How can I change my password?',
                    style: TextStyle(color: isDark ? AppColors.lightwhite : Colors.black),
                  ),
                  subtitle: const Text(
                    'Go to Settings > Password & Security.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        title: const Text('About Food Go'),
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        foregroundColor: isDark ? AppColors.lightwhite : Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fastfood, size: 85, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'Food Go',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Food ordering and delivery application.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
