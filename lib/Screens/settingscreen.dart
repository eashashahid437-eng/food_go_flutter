import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Controllers/settingScreencontroller.dart';
import 'package:food_go/Screens/BottomNavbar/orderhistory.dart';
import 'package:food_go/Screens/BottomNavbar/paymentscreen.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller =
        Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          // ======================================================
          // ACCOUNT
          // ======================================================

          _sectionTitle('Account'),

          _settingTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Manage your profile information',
            onTap: () => Get.back(),
          ),

          _settingTile(
            icon: Icons.location_on_outlined,
            title: 'Delivery Addresses',
            subtitle: 'Manage your delivery locations',
            onTap: () {
              Get.to(() => const AddressesScreen());
            },
          ),

          _settingTile(
            icon: Icons.lock_outline,
            title: 'Password & Security',
            subtitle: 'Manage your account security',
            onTap: () {
              Get.to(() => const SecurityScreen());
            },
          ),

          const SizedBox(height: 8),

          // ======================================================
          // FOOD GO
          // ======================================================

          _sectionTitle('Food Go'),

          _settingTile(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage your saved payment methods',
            onTap: () {
              Get.to(() => const PaymentDetailsScreen());
            },
          ),

          _settingTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Food Go Wallet',
            subtitle: 'Balance and wallet transactions',
            onTap: () {
              Get.to(() => const WalletScreen());
            },
          ),

          _settingTile(
            icon: Icons.favorite_border,
            title: 'Saved Items',
            subtitle: 'Your favorite food items',
            onTap: () {
              Get.to(() => const SavedItemsScreen());
            },
          ),

          _settingTile(
            icon: Icons.receipt_long_outlined,
            title: 'Orders',
            subtitle: 'View your previous orders',
            onTap: () {
              Get.to(() => const OrderHistoryScreen());
            },
          ),

          _settingTile(
            icon: Icons.calendar_month_outlined,
            title: 'Bookings',
            subtitle: 'Manage your bookings',
            onTap: () {
              Get.to(() => const BookingsScreen());
            },
          ),

          _settingTile(
            icon: Icons.card_giftcard_outlined,
            title: 'Rewards',
            subtitle: 'View your Food Go reward points',
            onTap: () {
              Get.to(() => const RewardsScreen());
            },
          ),

          _settingTile(
            icon: Icons.redeem_outlined,
            title: 'Gift Cards',
            subtitle: 'Manage and redeem gift cards',
            onTap: () {
              Get.to(() => const GiftCardsScreen());
            },
          ),

          _settingTile(
            icon: Icons.people_outline,
            title: 'Refer Friends',
            subtitle: 'Invite friends and earn rewards',
            onTap: () {
              Get.to(() => const ReferFriendsScreen());
            },
          ),

          const SizedBox(height: 8),

          // ======================================================
          // NOTIFICATIONS
          // ======================================================

          _sectionTitle('Notifications'),

          Obx(
            () => SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20),
              secondary: const Icon(
                Icons.notifications_none,
                color: Color(0xFFFF5722),
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Receive app notifications',
              ),
              value: controller.notificationsEnabled.value,
              activeColor: const Color(0xFFFF5722),
              onChanged: controller.toggleNotifications,
            ),
          ),

          Obx(
            () => SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20),
              secondary: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFFFF5722),
              ),
              title: const Text(
                'Order Updates',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Receive updates about your orders',
              ),
              value: controller.orderNotifications.value,
              activeColor: const Color(0xFFFF5722),
              onChanged:
                  controller.notificationsEnabled.value
                      ? controller.toggleOrderNotifications
                      : null,
            ),
          ),

          Obx(
            () => SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20),
              secondary: const Icon(
                Icons.local_offer_outlined,
                color: Color(0xFFFF5722),
              ),
              title: const Text(
                'Offers & Promotions',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Receive special offers and promotions',
              ),
              value:
                  controller.promotionalNotifications.value,
              activeColor: const Color(0xFFFF5722),
              onChanged:
                  controller.notificationsEnabled.value
                      ? controller.togglePromotionalNotifications
                      : null,
            ),
          ),

          const SizedBox(height: 8),

          // ======================================================
          // SUPPORT
          // ======================================================

          _sectionTitle('Support'),

          _settingTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with Food Go',
            onTap: () {
              Get.to(() => const HelpSupportScreen());
            },
          ),

          _settingTile(
            icon: Icons.info_outline,
            title: 'About Food Go',
            subtitle: 'App information and version',
            onTap: () {
              Get.to(() => const AboutScreen());
            },
          ),

          const SizedBox(height: 20),

          // ======================================================
          // LOGOUT
          // ======================================================

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Logout'),
                    content: const Text(
                      'Are you sure you want to logout?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

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

  // ============================================================
  // SETTING TILE
  // ============================================================

  static Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFFF5722).withOpacity(.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFF5722),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================================
// ADDRESSES SCREEN
// ============================================================================

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .collection('addresses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...docs.map(
                (doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                      title: Text(
                        data['title'] ?? 'Address',
                      ),
                      subtitle: Text(
                        data['address'] ?? '',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          controller.deleteAddress(doc.id);
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () {
                  _addAddressDialog(context, controller);
                },
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
  ) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Address title',
                hintText: 'Home / Work',
              ),
            ),
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Full address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addAddress(
                title: titleController.text,
                address: addressController.text,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECURITY SCREEN
// ============================================================================

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password & Security'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.security,
            size: 70,
            color: Color(0xFFFF5722),
          ),

          const SizedBox(height: 20),

          const Text(
            'Account Security',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: () {
              controller.changePassword(
                passwordController.text.trim(),
              );
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WALLET SCREEN
// ============================================================================

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Go Wallet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .snapshots(),
        builder: (context, snapshot) {
          double balance = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data =
                snapshot.data!.data() as Map<String, dynamic>?;

            balance =
                double.tryParse(
                  data?['walletBalance']?.toString() ?? '0',
                ) ??
                0;
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(25),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF5722),
                      Color(0xFFE91E63),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 35,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
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

              const Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                      .orderBy(
                        'createdAt',
                        descending: true,
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No wallet transactions yet.',
                        ),
                      );
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((doc) {
                        final data = doc.data()
                            as Map<String, dynamic>;

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.payment),
                          ),
                          title: Text(
                            data['title'] ??
                                'Transaction',
                          ),
                          subtitle: Text(
                            data['type'] ?? '',
                          ),
                          trailing: Text(
                            'Rs. ${data['amount'] ?? 0}',
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

// ============================================================================
// SAVED ITEMS
// ============================================================================

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .collection('savedItems')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
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
              final data =
                  doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  title: Text(
                    data['name'] ?? 'Food Item',
                  ),
                  subtitle: Text(
                    data['description'] ?? '',
                  ),
                  trailing: Text(
                    'Rs. ${data['price'] ?? ''}',
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

// ============================================================================
// BOOKINGS
// ============================================================================

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No bookings found.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data =
                  doc.data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Colors.orange,
                ),
                title: Text(
                  data['restaurant'] ?? 'Booking',
                ),
                subtitle: Text(
                  '${data['date'] ?? ''} • ${data['time'] ?? ''}',
                ),
                trailing: Text(
                  data['status'] ?? 'Pending',
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ============================================================================
// REWARDS
// ============================================================================

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(controller.uid)
            .snapshots(),
        builder: (context, snapshot) {
          int points = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data =
                snapshot.data!.data()
                    as Map<String, dynamic>?;

            points =
                int.tryParse(
                  data?['rewardPoints']?.toString() ?? '0',
                ) ??
                0;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 80,
                  color: Color(0xFFFF5722),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your Reward Points',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  '$points Points',
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
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

// ============================================================================
// GIFT CARDS
// ============================================================================

class GiftCardsScreen extends StatefulWidget {
  const GiftCardsScreen({super.key});

  @override
  State<GiftCardsScreen> createState() =>
      _GiftCardsScreenState();
}

class _GiftCardsScreenState extends State<GiftCardsScreen> {
  final TextEditingController codeController =
      TextEditingController();

  bool loading = false;

  Future<void> redeemCard() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      Get.snackbar(
        'Error',
        'Enter gift card code.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final uid =
          FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) return;

      final card = await FirebaseFirestore.instance
          .collection('giftCards')
          .doc(code)
          .get();

      if (!card.exists) {
        Get.snackbar(
          'Invalid Code',
          'Gift card does not exist.',
        );
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

      final amount =
          data['amount'] ?? 0;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'walletBalance': FieldValue.increment(
          (amount as num).toDouble(),
        ),
      }, SetOptions(merge: true));

      await card.reference.update({
        'used': true,
        'usedBy': uid,
        'usedAt': FieldValue.serverTimestamp(),
      });

      codeController.clear();

      Get.snackbar(
        'Success',
        'Gift card redeemed successfully.',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to redeem gift card.',
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Cards'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.card_giftcard,
              size: 80,
              color: Color(0xFFFF5722),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Gift Card Code',
                hintText: 'Enter your code',
                prefixIcon: Icon(Icons.redeem),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : redeemCard,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Redeem Gift Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// REFER FRIENDS
// ============================================================================

class ReferFriendsScreen extends StatelessWidget {
  const ReferFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    final referralCode =
        user?.uid.substring(0, 8).toUpperCase() ??
            'FOODGO';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer Friends'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people,
                size: 80,
                color: Color(0xFFFF5722),
              ),

              const SizedBox(height: 20),

              const Text(
                'Invite your friends to Food Go',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Share your referral code and earn rewards.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Text(
                  referralCode,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Referral Code',
                    'Your code is $referralCode',
                  );
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

// ============================================================================
// HELP & SUPPORT
// ============================================================================

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const SizedBox(height: 15),

          const Icon(
            Icons.support_agent,
            size: 75,
            color: Color(0xFFFF5722),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'How can we help?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Card(
            child: ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat Support'),
              subtitle: const Text(
                'Talk to Food Go support',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
              onTap: () {
                Get.snackbar(
                  'Support',
                  'Support chat will be available soon.',
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email Support'),
              subtitle: const Text(
                'support@foodgo.com',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
              onTap: () {
                Get.snackbar(
                  'Email',
                  'support@foodgo.com',
                );
              },
            ),
          ),

          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Frequently Asked Questions'),
              children: const [
                ListTile(
                  title: Text('How can I place an order?'),
                  subtitle: Text(
                    'Select your food item, add it to cart and complete checkout.',
                  ),
                ),
                ListTile(
                  title: Text('How can I track my order?'),
                  subtitle: Text(
                    'Open Orders from your profile to see your order status.',
                  ),
                ),
                ListTile(
                  title: Text('How can I change my password?'),
                  subtitle: Text(
                    'Go to Settings > Password & Security.',
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

// ============================================================================
// ABOUT
// ============================================================================

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Food Go'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fastfood,
                size: 85,
                color: Color(0xFFFF5722),
              ),
              const SizedBox(height: 20),
              const Text(
                'Food Go',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Food ordering and delivery application.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}