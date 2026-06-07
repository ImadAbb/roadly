import 'package:flutter/material.dart';
import 'package:roadly/componets/button.dart';
import 'package:roadly/assets/themes/colors.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 25),
            //app name
            Text(
              "ROADLY",
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 28,
                color: Colors.white,
              ),
            ),

            //road icon
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Image.asset(
                'lib/assets/images/travel.png',
                width: 500,
                height: 200,
              ),
            ),

            //title
            Text(
              "L'APP DE REFERENCE",
              style: const TextStyle(
                fontSize: 44,
                color: Colors.white,
                fontFamily: 'Serif',
              ),
            ),

            const SizedBox(height: 10),

            //subtitle
            Text(
              "Utilisez notre outil de calcul simple et intuitif pour faciliter le dimensionnement de toutes vos structures en travaux publics.",
              style: TextStyle(
                color: Colors.grey[200],
                height: 2,
              ),
              textAlign: TextAlign.left,
            ),

            SizedBox(height: 25,),
            //button
            MyButton(
              text: "Commencer",
              onTap: () {
                //go to dim menu
                Navigator.pushNamed(context, '/startpage');
              },
            ),
          ],
        ),
      ),
    );
  }
}
