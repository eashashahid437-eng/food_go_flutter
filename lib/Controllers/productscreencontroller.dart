import 'package:food_go/widgets/product_card.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  final FoodModel food;

  ProductDetailController({required this.food});

  late RxDouble spicyVal;

  final RxInt portionCount = 1.obs;

  @override
  void onInit() {
    super.onInit();
    spicyVal = food.spicyLevel.obs;
  }

  void changeSpicy(double value) {
    spicyVal.value = value.clamp(0.0, 5.0);
  }

  void increasePortion() {
    portionCount.value++;
  }

  void decreasePortion() {
    if (portionCount.value > 1) {
      portionCount.value--;
    }
  }

  double get totalPrice {
    return food.price * portionCount.value;
  }

  Map<String, dynamic> get orderItem {
    return {
      'productId': food.id.toString(),
      'productName': food.title,
      'subtitle': food.productname,
      'image': food.image,
      'price': food.price,
      'quantity': portionCount.value,
      'spicyLevel': spicyVal.value,
      'itemTotal': totalPrice,
    };
  }
}
