import 'package:flutter/material.dart';
import 'package:food_go/widgets/product_card.dart'; // Isme FoodModel mojood hai
import 'package:get/get.dart';
import 'package:food_go/screens/payment_method.dart'; // Apni payment_method.dart ka sahi path check kar lein

class ProductDetailScreen extends StatefulWidget {
  final FoodModel food;

  const ProductDetailScreen({
    super.key,
    required this.food,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  late double spicyVal;
  int portionCount = 1;

  @override
  void initState() {
    super.initState();

    spicyVal = widget.food.spicyLevel;
  }

  @override
  Widget build(BuildContext context) {
    // Real calculated total price
    double totalPrice = widget.food.price * portionCount;

    return Scaffold(
      backgroundColor: Colors.white,

      // =========================================================
      // APP BAR
      // =========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),

      // =========================================================
      // BODY
      // =========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =====================================================
            // PRODUCT IMAGE
            // =====================================================

            Center(
              child: Image.network(
                widget.food.image,

                height: 200,

                fit: BoxFit.contain,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.fastfood,
                    size: 100,
                    color: Colors.grey,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // TITLE
            // =====================================================

            Text(
              widget.food.title,

              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // =====================================================
            // PRODUCT NAME
            // =====================================================

            Text(
              widget.food.productname,

              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            // =====================================================
            // RATING + TIME
            // =====================================================

            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 18,
                ),

                const SizedBox(width: 4),

                Text(
                  widget.food.rating.toStringAsFixed(1),

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  "(${widget.food.reviewCount} reviews)",

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const Spacer(),

                const Text(
                  "14 mins",

                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =====================================================
            // DESCRIPTION
            // =====================================================

            Text(
              widget.food.description,

              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            // =====================================================
            // SPICY + PORTION HEADINGS
            // =====================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: const [
                Text(
                  "Spicy",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                Text(
                  "Portion",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // =====================================================
            // SPICY + PORTION
            // =====================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // =================================================
                // SPICY SECTION
                // =================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // -------------------------------
                      // SLIDER
                      // -------------------------------

                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,

                          activeTrackColor:
                              const Color(0xFFE53935),

                          inactiveTrackColor:
                              const Color(0xFFFFCDD2),

                          thumbColor:
                              const Color(0xFFE53935),

                          overlayColor:
                              const Color(0xFFE53935)
                                  .withOpacity(0.10),

                          thumbShape:
                              const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),

                          overlayShape:
                              const RoundSliderOverlayShape(
                            overlayRadius: 15,
                          ),
                        ),

                        child: Slider(
                          value: spicyVal.clamp(0, 5),

                          min: 0,

                          max: 5,

                          onChanged: (val) {
                            setState(() {
                              spicyVal = val;
                            });
                          },
                        ),
                      ),

                      // -------------------------------
                      // MILD + HOT
                      // -------------------------------

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          children: const [
                            Text(
                              "Mild",

                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Text(
                              "Hot",

                              style: TextStyle(
                                color: Color(0xFFE57373),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 25),

                // =================================================
                // PORTION SECTION
                // =================================================

                Row(
                  children: [
                    // -------------------------------
                    // MINUS BUTTON
                    // -------------------------------

                    Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: const Color(0xFFD92D2D),

                        borderRadius:
                            BorderRadius.circular(10),
                      ),

                      child: IconButton(
                        padding: EdgeInsets.zero,

                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 22,
                        ),

                        onPressed: () {
                          setState(() {
                            if (portionCount > 1) {
                              portionCount--;
                            }
                          });
                        },
                      ),
                    ),

                    // -------------------------------
                    // NUMBER
                    // -------------------------------

                    Container(
                      width: 38,

                      alignment: Alignment.center,

                      child: Text(
                        "$portionCount",

                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // -------------------------------
                    // PLUS BUTTON
                    // -------------------------------

                    Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: const Color(0xFFD92D2D),

                        borderRadius:
                            BorderRadius.circular(10),
                      ),

                      child: IconButton(
                        padding: EdgeInsets.zero,

                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),

                        onPressed: () {
                          setState(() {
                            portionCount++;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 35),

            // =====================================================
            // PRICE + ORDER BUTTON
            // =====================================================

            Row(
              children: [
                // =================================================
                // PRICE RED BOX
                // =================================================

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFD92D2D),

                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: Text(
                    "\$${totalPrice.toStringAsFixed(2)}",

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // =================================================
                // ORDER NOW
                // =================================================

                Expanded(
                  child: SizedBox(
                    height: 52,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF30252F),

                        foregroundColor: Colors.white,

                        elevation: 0,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),

                      onPressed: () {
                        // Real calculated price ke sath PaymentMethodScreen par navigate karna
                        Get.to(() => PaymentMethodScreen(totalPrice: totalPrice));
                      },

                      child: const Text(
                        "ORDER NOW",

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
