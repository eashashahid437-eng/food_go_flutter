// import 'package:flutter/material.dart';
// import 'package:food_go/Constants/image_path.dart';
// import 'package:food_go/Screens/profile_screen.dart';
// import 'package:food_go/utility/responsive.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:get/get.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Row(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Foodgo',
//                   textAlign: TextAlign.start,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//                 const Text(
//                   'Order Your Favorite Food!',
//                   style: TextStyle(
//                     color: AppColors.lightgrey,
//                     fontSize: 14,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),
//             GestureDetector(
//               onTap: () {
//                 Get.to(() => const ProfileScreen());
//               },
//               child: CircleAvatar(
//                 radius: 20,
//                 backgroundImage: AssetImage(ImagePath.appbarpic),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(
//           horizontal: MediaQuery.of(context).size.width * 0.05,
//           vertical: MediaQuery.of(context).size.height * 0.05,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.7,
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search for food...',
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: MediaQuery.of(context).size.width * 0.02),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.darkpink,
//                     minimumSize: const Size(50, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () {
//                     // Handle filter button press
//                   },
//                   child: Icon(Icons.tune, size: 22, color: Colors.white),
//                 ),
//               ],
//             ),
//             SizedBox(height: MediaQuery.of(context).size.height * 0.05),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       print("All tapped");
//                       // Get.to(() => NextScreen());
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.09,
//                         vertical: MediaQuery.of(context).size.height * 0.01,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.darkpink,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         'All',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(width: MediaQuery.of(context).size.width * 0.06),
//                   GestureDetector(
//                     onTap: () {
//                       print("All tapped");
//                       // Get.to(() => NextScreen());
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.09,
//                         vertical: MediaQuery.of(context).size.height * 0.01,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.lightwhite,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         'Combos',
//                         style: TextStyle(
//                           color: AppColors.lightgrey,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(width: MediaQuery.of(context).size.width * 0.06),
//                   GestureDetector(
//                     onTap: () {
//                       print("All tapped");
//                       // Get.to(() => NextScreen());
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.09,
//                         vertical: MediaQuery.of(context).size.height * 0.01,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.lightwhite,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         'Sliders',
//                         style: TextStyle(
//                           color: AppColors.lightgrey,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(width: MediaQuery.of(context).size.width * 0.06),
//                   GestureDetector(
//                     onTap: () {
//                       print("All tapped");
//                       // Get.to(() => NextScreen());
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.09,
//                         vertical: MediaQuery.of(context).size.height * 0.01,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.lightwhite,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         'Classic',
//                         style: TextStyle(
//                           color: AppColors.lightgrey,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(width: MediaQuery.of(context).size.width * 0.06),
//                   GestureDetector(
//                     onTap: () {
//                       print("All tapped");
//                       // Get.to(() => NextScreen());
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.09,
//                         vertical: MediaQuery.of(context).size.height * 0.01,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.lightwhite,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         'Spicy',
//                         style: TextStyle(
//                           color: AppColors.lightgrey,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: MediaQuery.of(context).size.width * 0.06),
//                 ],
//               ),
//             ),



//           ],
//         ),
//       ),
//     );
//   }
// }
