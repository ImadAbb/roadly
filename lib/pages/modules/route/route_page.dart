import 'package:flutter/material.dart';
import 'package:roadly/componets/button.dart';
import 'package:roadly/pages/modules/route/cbr.dart';

class ModuleRoute extends StatefulWidget {
  const ModuleRoute({super.key});

  @override
  State<ModuleRoute> createState() => _ModuleRouteState();
}

class _ModuleRouteState extends State<ModuleRoute> {
  String? selectedMethod; // garde la méthode choisie

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[100],
        elevation: 0,
        toolbarHeight: 60,
        title: Text(
          selectedMethod != null ? "ROUTE $selectedMethod" : "ROUTE",
          style: TextStyle(fontFamily: 'Serif', fontSize: 28),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 15, left: 15, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                "Choisissez la méthode à utiliser :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MethodButton(
                  method: "CBR",
                  isSelected: selectedMethod == "CBR",
                  onTap: () => setState(() => selectedMethod = "CBR"),
                ),
                MethodButton(
                  method: "Asphalt Institu",
                  isSelected: selectedMethod == "Asphalt Institu",
                  onTap: () =>
                      setState(() => selectedMethod = "Asphalt Institu"),
                ),
                MethodButton(
                  method: "CTTP",
                  isSelected: selectedMethod == "CTTP",
                  onTap: () => setState(() => selectedMethod = "CTTP"),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (selectedMethod != null)
              Expanded(
                child: _buildMethodContent(selectedMethod!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodContent(String method) {
    switch (method) {
      case "CBR":
        return const CBRRoute();
      case "Asphalt Institu":
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              20,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Asphalt Institu - GOTLEK MAZAL YA 7IMAR ${index + 1}",
                ),
              ),
            ),
          ),
        );
      case "CTTP":
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              20,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("CTTP - GOTLEK MAZAL YA 7IMAR ${index + 1}"),
              ),
            ),
          ),
        );
      default:
        return const Text("Méthode inconnue");
    }
  }
}
