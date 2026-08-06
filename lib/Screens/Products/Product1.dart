import 'package:flutter/material.dart';

class Product1 extends StatelessWidget {
  const Product1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product 1'),
      ),
      body: const Center(
        child: Text('This is Product 1 Screen'),
      ),
    );
  }
}