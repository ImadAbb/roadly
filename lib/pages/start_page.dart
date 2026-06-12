import 'package:flutter/material.dart';
import 'package:roadly/componets/button.dart';
import 'package:roadly/componets/modules.dart';
import 'package:roadly/componets/modules_tile.dart';
import 'package:roadly/pages/allyoucando/allyou/introduction.dart';
import 'package:roadly/pages/modules/hydraulique/hydraulique_page.dart';
import 'package:roadly/pages/modules/ponts/ponts_main.dart';
import 'package:roadly/pages/modules/route/route_page.dart';
import 'package:roadly/pages/modules/structure/strmtc_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List modulesList = [
    Modules(
      name: "Route", 
      lastUpdate: "9 Juin", 
      icon: Icons.roundabout_left,
      page: const ModuleRoute(),
    ),
    Modules(
      name: "Hydraulique", 
      lastUpdate: "7 Juin", 
      icon: Icons.water_drop,
      page: ModuleHydraulique(),
    ),
    Modules(
      name: "Structure Métalique",
      lastUpdate: "7 Juin",
      icon: Icons.iron,
      page: ModuleStructureMetallique()
    ),
    Modules(
      name: "Ponts", 
      lastUpdate: "12 juin", 
      icon: Icons.add_road, 
      page: ModulePonts()
    )
  ];

  double scrollOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
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
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 21, 115, 192), // Rouge vif (Red 600)
                  Color.fromARGB(255, 38, 118, 255), // Deep Orange 700
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        MyButton(
                          text: 'Afficher les crédits',
                          onTap: () {
                            Navigator.pushNamed(context, '/creditspage');
                          },
                        ),
                      ],
                    ),
                  ],
                ),


                Image.asset(
                  'lib/assets/images/USTHB2.png',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  cacheHeight: 200,
                  cacheWidth: 200,
                  color: Colors.black,
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
                hintText: "Rechercher ...",
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
            child: Text(
              "Choisissez votre structure:",
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
              scrollDirection: Axis.horizontal,
              itemCount: modulesList.length,
              itemBuilder: (context, index) {
                return ModulesTile(
                  modules: modulesList[index], 
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => modulesList[index].page),
                    );
                  }
                );
              }
            ),
          ),

          SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => Introduction(),
                  ),
                );
              },
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 21, 115, 192), // Rouge vif (Red 600)
                      Color.fromARGB(255, 38, 85, 255), // Deep Orange 700
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Voir tous ce que vous pouvez faire  👀",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
