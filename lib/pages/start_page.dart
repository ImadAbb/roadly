import 'package:flutter/material.dart';
import 'package:roadly/componets/button.dart';
import 'package:roadly/componets/modules.dart';
import 'package:roadly/componets/modules_tile.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  List modulesList = [
    Modules(name: "Route", lastUpdate: "7 Juin", icon: Icons.roundabout_left),
    Modules(name: "Hydraulique", lastUpdate: "7 Juin", icon: Icons.water_drop),
    Modules(name: "Structure Métalique", lastUpdate: "7 Juin", icon: Icons.iron)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.grey[900]),
        title: Text(
          'ROADLY',
          style: TextStyle(
            color: Colors.grey[900],
            fontFamily: 'Serif',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //AppInfo & crédits
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 138, 60, 55),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "L'app à tout dimentionner",
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        MyButton(text: 'Afficher les crédits', onTap: () {}),
                      ],
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                Image.asset(
                  'lib/assets/images/USTHB2.png',
                  height: 99,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 62, 5, 5),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 255, 69, 69),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text("Choisissez votre structure:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: modulesList.length,
              itemBuilder: (context, index) {
                return ModulesTile(modules: modulesList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
