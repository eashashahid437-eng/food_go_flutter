import 'package:flutter/material.dart';

class Product4 extends StatelessWidget {
  const Product4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product 4'),
      ),
      body: const Center(
        child: Text('This is Product 4 Screen'),
      ),
    );
  }
}