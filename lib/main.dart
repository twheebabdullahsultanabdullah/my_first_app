
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('تطبيقي الأول'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Text(
            'مرحباً بك في Flutter',
            style: TextStyle(fontSize: 25),
          ),
        ),
      ),
    );
  }
}