import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController {
  final box = GetStorage();
  var cartItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    var savedCart = box.read('cart_data');
    if (savedCart != null) {
      cartItems.assignAll(List<Map<String, dynamic>>.from(savedCart));
    }
  }

  
  void addToCart(Map<String, dynamic> item) {
    cartItems.add(item);
    _saveToStorage();
  }

  
  void removeItem(int index) {
    cartItems.removeAt(index);
    _saveToStorage();
  }

  
  void increaseQuantity(int index) {
    var item = cartItems[index];
    int currentQty = _safeInt(item['quantity']);
    currentQty++;
    item['quantity'] = currentQty;
    
    item['itemTotal'] = _calculateItemTotal(item);

    cartItems[index] = item;
    cartItems.refresh();
    _saveToStorage();
  }


  void decreaseQuantity(int index) {
    var item = cartItems[index];
    int currentQty = _safeInt(item['quantity']);
    if (currentQty > 1) {
      currentQty--;
      item['quantity'] = currentQty;
      item['itemTotal'] = _calculateItemTotal(item);

      cartItems[index] = item;
      cartItems.refresh();
      _saveToStorage();
    }
  }

  
  void clearCart() {
    cartItems.clear();
    _saveToStorage();
  }

  
  void _saveToStorage() {
    box.write('cart_data', cartItems.toList());
  }


  double _calculateItemTotal(Map<String, dynamic> item) {
    int qty = _safeInt(item['quantity']);
    
    if (item['toppings'] != null) {
      List toppings = item['toppings'];
      double toppingsSum = toppings.fold(0.0, (sum, t) => sum + _toDouble(t['price']));
      double base = _toDouble(item['basePrice'] ?? item['price']);
      return (base + toppingsSum) * qty;
    }
    
    double unitPrice = _toDouble(item['price'] ?? item['basePrice']);
    return unitPrice * qty;
  }

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) {
      return sum + _toDouble(item['itemTotal']);
    });
  }

  double get taxes => subtotal * 0.05; 
  double get deliveryFee => cartItems.isEmpty ? 0.0 : 1.50;
  double get totalAmount => subtotal + taxes + deliveryFee;

  double _toDouble(dynamic val) {
    if (val is num) return val.toDouble();
    return double.tryParse(val?.toString() ?? '') ?? 0.0;
  }

  int _safeInt(dynamic val) {
    if (val is num) return val.toInt();
    return int.tryParse(val?.toString() ?? '') ?? 1;
  }
}
