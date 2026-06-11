import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:roadly/componets/gradient_text.dart';

class PageThree extends StatelessWidget {
  const PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(160, 76, 175, 79),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  GradientText(
                    "Comment utiliser notre interface ?", 
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 20,
                      color: Colors.grey[900],
                      fontWeight: FontWeight.bold
                    ),
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(255, 29, 6, 97), const Color.fromARGB(255, 16, 10, 136)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  )
                ],
              ),

              const SizedBox(height: 15),

              Text(
                "Notre application à pour but de vous simplifiez la vie, quoi de mieux qu'une interface moderne et facile à utiliser.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),                
                decoration: BoxDecoration(
                  color: const Color.fromARGB(100, 21, 104, 8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Les différentes structures sont rangées séparément",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    LottieBuilder.asset(
                      'lib/assets/lottie/anime6rowview.json',
                      width: 250,
                    )

                  ],
                ),
              ),

              const SizedBox(height: 20,),

              Container(
                padding: const EdgeInsets.all(16),                
                decoration: BoxDecoration(
                  color: const Color.fromARGB(100, 21, 104, 8),
                  borderRadius: BorderRadius.circular(20),
                ),                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Saisissez vos données facilement",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    LottieBuilder.asset(
                      'lib/assets/lottie/anime5answers.json',
                      width: 500,
                    )
                  ],
                ),
              ),              
            ],
          ),
        ),
      ),
    );
  }
}