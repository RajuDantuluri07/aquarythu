import 'package:flutter/material.dart';

void main() {
  runApp(const AquaRythuApp());
}

class AquaRythuApp extends StatelessWidget {
  const AquaRythuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("AquaRythu"),
        ),
        body: const Center(
          child: Text(
            "Welcome to AquaRythu 🚀",
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }
}
