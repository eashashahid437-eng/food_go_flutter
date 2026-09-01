
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  final List<String> categories = [
    'All',
    'Combos',
    'Sliders',
    'Classic',
    'Spicy',
  ];

  final RxString selectedFilter = 'none'.obs;

  Stream<QuerySnapshot> get productsStream {
    return FirebaseFirestore.instance.collection('product').snapshots();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.toLowerCase().trim();
    update();
  }

  void clearSearch() {
    searchQuery.value = '';
    update();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    update(); // Instantly notifies GetX listeners
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
    update(); // Instantly notifies GetX listeners
  }

  bool categoryMatches(String dbCategory) {
    if (selectedCategory.value == 'All') {
      return true;
    }

    final String currentCategory = selectedCategory.value.toLowerCase().trim();
    dbCategory = dbCategory.toLowerCase().trim();

    // Plural (s) mismatch handling (e.g., Combo vs Combos)
    if (currentCategory.endsWith('s') &&
        currentCategory.substring(0, currentCategory.length - 1) ==
            dbCategory) {
      return true;
    }

    if (dbCategory.endsWith('s') &&
        dbCategory.substring(0, dbCategory.length - 1) == currentCategory) {
      return true;
    }

    return dbCategory == currentCategory;
  }

  bool searchMatches(Map<String, dynamic> data) {
    if (searchQuery.value.isEmpty) {
      return true;
    }

    final String title = (data['title'] ?? '').toString().toLowerCase();
    final String productName =
        (data['productname'] ?? '').toString().toLowerCase();
    final String subtitle = (data['subtitle'] ?? '').toString().toLowerCase();

    return title.contains(searchQuery.value) ||
        productName.contains(searchQuery.value) ||
        subtitle.contains(searchQuery.value);
  }

  List<QueryDocumentSnapshot> getFilteredProducts(QuerySnapshot snapshot) {
    List<QueryDocumentSnapshot> docs = snapshot.docs.toList();

    // 1. Filter by Category
    docs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final String category = (data['category'] ?? '').toString();
      return categoryMatches(category);
    }).toList();

    // 2. Filter by Search Text
    docs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return searchMatches(data);
    }).toList();

    // 3. Apply Sorting
    if (selectedFilter.value == 'low') {
      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final double priceA = _toDouble(dataA['price']);
        final double priceB = _toDouble(dataB['price']);
        return priceA.compareTo(priceB);
      });
    }

    if (selectedFilter.value == 'high') {
      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final double priceA = _toDouble(dataA['price']);
        final double priceB = _toDouble(dataB['price']);
        return priceB.compareTo(priceA);
      });
    }

    if (selectedFilter.value == 'rating') {
      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final double ratingA = _toDouble(dataA['rating']);
        final double ratingB = _toDouble(dataB['rating']);
        return ratingB.compareTo(ratingA);
      });
    }

    return docs;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// // Cached Network Image package import kiya gaya hai

// class HomeController extends GetxController {
//   final RxString searchQuery = ''.obs;
//   final RxString selectedCategory = 'All'.obs;

//   final List<String> categories = [
//     'All',
//     'Combos',
//     'Sliders',
//     'Classic',
//     'Spicy',
//   ];

//   final RxString selectedFilter = 'none'.obs;

//   Stream<QuerySnapshot> get productsStream {
//     return FirebaseFirestore.instance.collection('product').snapshots();
//   }

//   void setSearchQuery(String value) {
//     searchQuery.value = value.toLowerCase().trim();
//   }

//   void clearSearch() {
//     searchQuery.value = '';
//   }

//   void selectCategory(String category) {
//     selectedCategory.value = category;
//   }

//   void selectFilter(String filter) {
//     selectedFilter.value = filter;
//   }

//   bool categoryMatches(String dbCategory) {
//     if (selectedCategory.value == 'All') {
//       return true;
//     }

//     final String currentCategory = selectedCategory.value.toLowerCase().trim();
//     dbCategory = dbCategory.toLowerCase().trim();

//     if (currentCategory.endsWith('s') &&
//         currentCategory.substring(0, currentCategory.length - 1) ==
//             dbCategory) {
//       return true;
//     }

//     if (dbCategory.endsWith('s') &&
//         dbCategory.substring(0, dbCategory.length - 1) == currentCategory) {
//       return true;
//     }

//     return dbCategory == currentCategory;
//   }

//   bool searchMatches(Map<String, dynamic> data) {
//     if (searchQuery.value.isEmpty) {
//       return true;
//     }

//     final String title = (data['title'] ?? '').toString().toLowerCase();
//     final String productName = (data['productname'] ?? '')
//         .toString()
//         .toLowerCase();
//     final String subtitle = (data['subtitle'] ?? '').toString().toLowerCase();

//     return title.contains(searchQuery.value) ||
//         productName.contains(searchQuery.value) ||
//         subtitle.contains(searchQuery.value);
//   }

//   List<QueryDocumentSnapshot> getFilteredProducts(QuerySnapshot snapshot) {
//     List<QueryDocumentSnapshot> docs = snapshot.docs.toList();

//     docs = docs.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       final String category = (data['category'] ?? '').toString();
//       return categoryMatches(category);
//     }).toList();

//     docs = docs.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       return searchMatches(data);
//     }).toList();

//     if (selectedFilter.value == 'low') {
//       docs.sort((a, b) {
//         final dataA = a.data() as Map<String, dynamic>;
//         final dataB = b.data() as Map<String, dynamic>;
//         final double priceA = _toDouble(dataA['price']);
//         final double priceB = _toDouble(dataB['price']);
//         return priceA.compareTo(priceB);
//       });
//     }

//     if (selectedFilter.value == 'high') {
//       docs.sort((a, b) {
//         final dataA = a.data() as Map<String, dynamic>;
//         final dataB = b.data() as Map<String, dynamic>;
//         final double priceA = _toDouble(dataA['price']);
//         final double priceB = _toDouble(dataB['price']);
//         return priceB.compareTo(priceA);
//       });
//     }

//     if (selectedFilter.value == 'rating') {
//       docs.sort((a, b) {
//         final dataA = a.data() as Map<String, dynamic>;
//         final dataB = b.data() as Map<String, dynamic>;
//         final double ratingA = _toDouble(dataA['rating']);
//         final double ratingB = _toDouble(dataB['rating']);
//         return ratingB.compareTo(ratingA);
//       });
//     }

//     return docs;
//   }

//   double _toDouble(dynamic value) {
//     if (value is num) {
//       return value.toDouble();
//     }
//     return double.tryParse(value?.toString() ?? '') ?? 0.0;
//   }
// }
