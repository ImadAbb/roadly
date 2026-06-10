import 'package:flutter/material.dart';

class PageThree extends StatelessWidget {
  const PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Container(
          child: Text("Page Three", style: TextStyle(
            fontSize: 20
          ),),
        ),
      ),
    );
  }
}