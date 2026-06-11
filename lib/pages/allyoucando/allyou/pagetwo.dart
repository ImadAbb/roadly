import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(160, 76, 175, 79),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text("Une interface adaptée à vos besoin",
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 23,
                        decoration: TextDecoration.underline,  
                        color: Colors.grey[900]                
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              LottieBuilder.asset('lib/assets/lottie/anime4appview.json'),

              Text("Une interface claire pour des résultats précis.",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[900]
                ),
              ),

              SizedBox()
            ],            
          ),
        )
      )
    );
  }
}