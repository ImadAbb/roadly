import 'package:flutter/material.dart';
import 'package:roadly/assets/themes/colors.dart';
import 'package:roadly/componets/button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoadlyColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool landscape =
                constraints.maxWidth > constraints.maxHeight;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 50,
                  ),
                  child: landscape
                      ? _buildLandscape(context)
                      : _buildPortrait(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),

        const Text(
          "ROADLY",
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 30,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 40),

        Center(
          child: Image.asset(
            'lib/assets/images/travel.png',
            height: 220,
          ),
        ),

        const SizedBox(height: 40),

        const Text(
          "L'APP DE RÉFÉRENCE",
          style: TextStyle(
            fontSize: 42,
            color: Colors.white,
            fontFamily: 'Serif',
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "Utilisez notre outil de calcul simple et intuitif pour faciliter le dimensionnement de toutes vos structures en travaux publics.",
          style: TextStyle(
            color: Colors.grey[200],
            height: 1.8,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 45),

        MyButton(
          text: "Commencer",
          onTap: () {
            Navigator.pushNamed(context, '/startpage');
          },
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Image.asset(
                'lib/assets/images/travel.png',
                height: 230,
              ),
            ),
          ),

          const SizedBox(width: 30),

          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ROADLY",
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "L'APP DE RÉFÉRENCE",
                  style: TextStyle(
                    fontSize: 34,
                    color: Colors.white,
                    fontFamily: 'Serif',
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  "Utilisez notre outil de calcul simple et intuitif pour faciliter le dimensionnement de toutes vos structures en travaux publics.",
                  style: TextStyle(
                    color: Colors.grey[200],
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: 220,
                  child: MyButton(
                    text: "Commencer",
                    onTap: () {
                      Navigator.pushNamed(context, '/startpage');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}