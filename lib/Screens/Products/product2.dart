import 'package:flutter/material.dart';

class Product2 extends StatelessWidget {
  const Product2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product 2'),
      ),
      body: const Center(
        child: Text('This is Product 2 Screen'),
      ),
    );
  }
}