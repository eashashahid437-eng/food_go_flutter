import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // Yahan maine ek simple Scaffold daal diya hai 'const ()' ki jagah
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Food Go'),
        ),
        body: const Center(
          child: Text('Firebase Connected Successfully!'),
        ),
      ),
    );
  }
}


