import 'package:flutter/material.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Container(
          child: Text("Page One", style: TextStyle(
            fontSize: 20
          ),),
        ),
      ),
    );
  }
}
