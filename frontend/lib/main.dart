import 'package:flutter/material.dart';

void main() {
  runApp(const PharmaPulseApp());
}

class PharmaPulseApp extends StatelessWidget {
  const PharmaPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaPulse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('PharmaPulse UI (В розробці)'),
        ),
      ),
    );
  }
}