import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_go/Constants/app_colors.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          "Order History",
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
        ),
      ),
      body: currentUser == null
          ? const Center(
              child: Text(
                "Please log in to view your orders.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.darkpink),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Unable to load orders.\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final List<QueryDocumentSnapshot> ordersDocs =
                    snapshot.data?.docs ?? [];

                if (ordersDocs.isEmpty) {
                  return _buildEmptyOrders(isDark);
                }

                int pendingCount = 0;
                int ongoingCount = 0;
                int completedCount = 0;

                for (final doc in ordersDocs) {
                  final data = doc.data() as Map<String, dynamic>;

                  final String status = (data['status'] ?? 'Pending')
                      .toString()
                      .toLowerCase();

                  if (status == 'pending') {
                    pendingCount++;
                  } else if (status == 'ongoing' ||
                      status == 'preparing' ||
                      status == 'shipping' ||
                      status == 'out for delivery' ||
                      status == 'on the way') {
                    ongoingCount++;
                  } else if (status == 'completed' || status == 'delivered') {
                    completedCount++;
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              "PENDING",
                              pendingCount.toString(),
                              Colors.orange,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              "ONGOING",
                              ongoingCount.toString(),
                              Colors.blue,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              "COMPLETED",
                              completedCount.toString(),
                              Colors.green,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "Recent Orders",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ListView.builder(
                        itemCount: ordersDocs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final data =
                              ordersDocs[index].data() as Map<String, dynamic>;

                          return _buildOrderCard(data, index, isDark);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyOrders(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 45,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No Orders Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't placed any orders yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> data, int index, bool isDark) {
    final String orderId = (data['orderId'] ?? 'Unknown').toString();

    final List<dynamic> items = data['items'] is List
        ? data['items'] as List<dynamic>
        : [];

    String itemName = "Food Order";

    if (items.isNotEmpty && items.first is Map) {
      final firstItem = Map<String, dynamic>.from(items.first as Map);

      itemName =
          (firstItem['productName'] ?? firstItem['title'] ?? 'Food Order')
              .toString();
    }

    final int moreItems = items.length > 1 ? items.length - 1 : 0;

    final double total = _toDouble(data['totalAmount']);

    final String status = (data['status'] ?? 'Pending').toString();

    final Color statusColor = _getStatusColor(status);

    final String paymentStatus = (data['paymentStatus'] ?? 'Paid').toString();

    final String date = _formatDate(data['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FOOD IMAGE (ColorFiltered aur BlendMode completely removed)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildFoodImage(items, isDark),
              ),

              const SizedBox(width: 14),

              // ORDER INFORMATION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (moreItems > 0) ...[
                      const SizedBox(height: 3),
                      Text(
                        "+ $moreItems more item${moreItems > 1 ? 's' : ''}",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      "ID: $orderId",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // PRICE
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _buildStatusBadge(status, statusColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, size: 15, color: Colors.grey.shade400),
                    const SizedBox(width: 5),
                    Text(
                      _paymentMethodName(data['paymentMethod']),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      paymentStatus.toLowerCase() == 'paid'
                          ? Icons.check_circle
                          : Icons.pending,
                      size: 15,
                      color: paymentStatus.toLowerCase() == 'paid'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      paymentStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: paymentStatus.toLowerCase() == 'paid'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(List<dynamic> items, bool isDark) {
    String image = "";

    if (items.isNotEmpty && items.first is Map) {
      final firstItem = Map<String, dynamic>.from(items.first as Map);

      image = (firstItem['image'] ?? '').toString();
    }

    // NETWORK IMAGE
    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: 65,
        height: 65,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return _defaultFoodIcon(isDark);
        },
      );
    }

    // ASSET IMAGE
    if (image.isNotEmpty) {
      return Image.asset(
        image,
        width: 65,
        height: 65,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return _defaultFoodIcon(isDark);
        },
      );
    }

    return _defaultFoodIcon(isDark);
  }

  Widget _defaultFoodIcon(bool isDark) {
    return Container(
      width: 65,
      height: 65,
      color: isDark ? AppColors.backgroundDark : Colors.grey.shade100,
      child: const Icon(Icons.fastfood, color: AppColors.darkpink, size: 30),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final String value = status.toLowerCase();

    if (value == 'delivered' || value == 'completed') {
      return Colors.green;
    }

    if (value == 'ongoing' ||
        value == 'preparing' ||
        value == 'shipping' ||
        value == 'out for delivery' ||
        value == 'on the way') {
      return Colors.blue;
    }

    return Colors.orange;
  }

  String _paymentMethodName(dynamic method) {
    switch (method?.toString()) {
      case 'credit_card':
        return "Credit Card";
      case 'debit_card':
        return "Debit Card";
      case 'jazzcash':
        return "JazzCash";
      case 'easypaisa':
        return "EasyPaisa";
      default:
        return "Payment";
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return "Date unavailable";
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) {
      return "Date unavailable";
    }

    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');

    return "$day/$month/$year  $hour:$minute";
  }

  Widget _buildStatCard(String title, String count, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}


