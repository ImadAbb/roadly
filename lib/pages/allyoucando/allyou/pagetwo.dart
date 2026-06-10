import 'package:flutter/material.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Container(
          child: Text("Page Two", style: TextStyle(
            fontSize: 20
          ),),
        ),
      ),
    );
  }
}