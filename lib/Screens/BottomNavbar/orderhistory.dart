import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(child: Text("Please log in to view your orders."))
          : StreamBuilder<QuerySnapshot>(
              // Firebase Firestore se real-time orders fetch kar rahe hain
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
                }

                var ordersDocs = snapshot.hasData ? snapshot.data!.docs : [];

                // Stats calculation
                int pendingCount = 0;
                int ongoingCount = 0;
                int completedCount = 0;

                for (var doc in ordersDocs) {
                  var data = doc.data() as Map<String, dynamic>;
                  String status = (data["status"] ?? "").toLowerCase();
                  if (status == "pending") {
                    pendingCount++;
                  } else if (status == "ongoing" || status == "shipping") {
                    ongoingCount++;
                  } else if (status == "completed" || status == "delivered") {
                    completedCount++;
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Top Stats Cards (Jaise Screenshot mein hain) ---
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("PENDING", "$pendingCount", Colors.orange)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildStatCard("ONGOING", "$ongoingCount", Colors.blue)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildStatCard("COMPLETED", "$completedCount", Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        "Recent Orders",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 15),

                      // --- Agar Orders Na Hon ---
                      if (ordersDocs.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Center(
                            child: Text(
                              "You haven't placed any orders yet!",
                              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),

                      // --- Orders List from Firebase ---
                      ListView.builder(
                        itemCount: ordersDocs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var orderData = ordersDocs[index].data() as Map<String, dynamic>;
                          String orderId = orderData["orderId"] ?? "#ORD-${1000 + index}";
                          String itemName = orderData["item"] ?? "Delicious Meal";
                          String price = orderData["price"] ?? "\$0.00";
                          String date = orderData["date"] ?? "Today";
                          String status = orderData["status"] ?? "Pending";

                          Color statusColor;
                          if (status.toLowerCase() == "delivered" || status.toLowerCase() == "completed") {
                            statusColor = Colors.green;
                          } else if (status.toLowerCase() == "ongoing" || status.toLowerCase() == "shipping") {
                            statusColor = Colors.blue;
                          } else {
                            statusColor = Colors.orange;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Food Image Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 65,
                                    height: 65,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.fastfood, color: Color(0xFFFF5722), size: 30),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Order Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itemName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "ID: $orderId",
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        date,
                                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price & Status Badge
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      price,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Widget for Top Stats Cards
  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
