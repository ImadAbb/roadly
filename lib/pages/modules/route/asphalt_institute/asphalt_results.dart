import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AsphaltResults extends StatefulWidget {
  final VoidCallback onBackToForm;

  const AsphaltResults({super.key, required this.onBackToForm});

  @override
  State<AsphaltResults> createState() => _AsphaltResultsState();
}

class _AsphaltResultsState extends State<AsphaltResults> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Lottie.asset('lib/assets/lottie/anime8under_construction.json'),
                
              Center(
                child: Text(
                  "Cette fonctionnalité est en cours de construction ...",
                  style: TextStyle(
                    fontFamily: 'Serif',
                    decoration: TextDecoration.underline,
                    color: Colors.grey[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        widget.onBackToForm();
      },
    );
  }
}
