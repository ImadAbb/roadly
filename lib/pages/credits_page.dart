import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Crédits & Informations',
          style: TextStyle(
            color: Colors.grey[900],
            fontFamily: 'Serif',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[200]!, Colors.grey[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Image.asset('lib/assets/images/r.png', height: 25, ),
                title: Text("Application"),
                subtitle: Text("Roadly"),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.blue, size: 30),
                title: Text("Développé par"),
                subtitle: Text("Abbas Imad"),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.track_changes, color: const Color.fromARGB(255, 33, 194, 243), size: 30),
                title: Text("But"),
                subtitle: Text("Projet personnel pour améliorer mes compétences en design"),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.favorite, color: Colors.red, size: 30),
                title: Text("Remerciements"),
                subtitle: Text("Merci à l’USTHB et aux encadrants pour leur soutien."),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.build, color: Colors.green, size: 30),
                title: Text("Technologies utilisées"),
                subtitle: Text("Flutter, Dart, Material Design"),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.description, color: Colors.orange, size: 30),
                title: Text("Licence"),
                subtitle: Text("© 2026 ROADLY – Tous droits réservés"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
