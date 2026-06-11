import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Bienvenu à ",
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'Serif',
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[900],
                        ),
                      ),
                      Text(
                        " ROADLY",
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.grey[900],
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Développé par des ingénieurs pour les ingénieurs.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Lottie.asset('lib/assets/lottie/anime1carroad.json'),

                  const SizedBox(height: 30),

                  Text(
                    "Optimisez vos projets dès aujourd'hui",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[900]
                    ),
                  ),
                ],
              ),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
