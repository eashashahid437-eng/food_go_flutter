import 'package:flutter/material.dart';

class Product3 extends StatelessWidget {
  const Product3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product 3'),
      ),
      body: const Center(
        child: Text('This is the Product 3 Screen'),
      ),
    );
  }
}