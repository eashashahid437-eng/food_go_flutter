import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:food_go/widgets/product_card.dart';

class FavoriteController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<FoodModel> favoriteList = <FoodModel>[].obs;

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get favoritesReference {
    final user = currentUser;

    if (user == null) {
      throw Exception("User is not logged in");
    }

    return _firestore.collection('users').doc(user.uid).collection('favorites');
  }

  Future<void> loadFavorites() async {
    try {
      final user = currentUser;

      if (user == null) {
        favoriteList.clear();
        globalFavoriteList.clear();
        return;
      }

      final snapshot = await favoritesReference.get();

      final List<FoodModel> loadedFavorites = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final food = FoodModel(
          id: _toInt(data['id']),
          image: (data['image'] ?? '').toString(),
          title: (data['title'] ?? '').toString(),
          productname: (data['productname'] ?? '').toString(),
          subtitle: (data['subtitle'] ?? '').toString(),
          price: _toDouble(data['price']),
          description: (data['description'] ?? '').toString(),
          spicyLevel: _toDouble(data['spicyLevel']),
          rating: _toDouble(data['rating']),
          reviewCount: _toInt(data['reviewCount']),
          isFavorite: true,
        );

        loadedFavorites.add(food);
      }

      favoriteList.assignAll(loadedFavorites);

      globalFavoriteList
        ..clear()
        ..addAll(loadedFavorites);
    } catch (e) {
      print("Load favorites error: $e");
    }
  }

  Future<void> addFavorite(FoodModel food) async {
    try {
      final user = currentUser;

      if (user == null) {
        Get.snackbar("Login Required", "Please login first to add favorites.");
        return;
      }

      food.isFavorite = true;

      final String favoriteId = food.id.toString();

      await favoritesReference.doc(favoriteId).set({
        'id': food.id,
        'image': food.image,
        'title': food.title,
        'productname': food.productname,
        'subtitle': food.subtitle,
        'price': food.price,
        'description': food.description,
        'spicyLevel': food.spicyLevel,
        'rating': food.rating,
        'reviewCount': food.reviewCount,
        'isFavorite': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!favoriteList.contains(food)) {
        favoriteList.add(food);
      }

      if (!globalFavoriteList.contains(food)) {
        globalFavoriteList.add(food);
      }
    } catch (e) {
      print("Add favorite error: $e");
    }
  }

  Future<void> removeFavorite(FoodModel food) async {
    try {
      final user = currentUser;

      if (user == null) {
        return;
      }

      food.isFavorite = false;

      await favoritesReference.doc(food.id.toString()).delete();

      favoriteList.removeWhere((item) => item.id == food.id);

      globalFavoriteList.removeWhere((item) => item.id == food.id);
    } catch (e) {
      print("Remove favorite error: $e");
    }
  }

  Future<void> toggleFavorite(FoodModel food) async {
    final exists = favoriteList.any((item) => item.id == food.id);

    if (exists) {
      await removeFavorite(food);
    } else {
      await addFavorite(food);
    }
  }

  bool isFavorite(FoodModel food) {
    return favoriteList.any((item) => item.id == food.id);
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
