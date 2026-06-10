import 'package:flutter/material.dart';
import 'package:roadly/componets/button.dart';
import 'package:roadly/pages/modules/route/cbr.dart';

class ModuleRoute extends StatefulWidget {
  const ModuleRoute({super.key});

  @override
  State<ModuleRoute> createState() => _ModuleRouteState();
}

class _ModuleRouteState extends State<ModuleRoute> {
  String? selectedMethod;
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  CBRResults? results;

  void _onValidated(CBRResults validatedResults) {
    setState(() {
      results = validatedResults;
      _selectedIndex = 1;
    });
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 100.0,
              floating: true,
              snap: true,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  selectedMethod != null ? "ROUTE $selectedMethod" : "ROUTE",
                  style: const TextStyle(fontFamily: 'Serif', fontSize: 22),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
      
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 15),
                  const Center(
                    child: Text(
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
                        method: "Asphalt Institute",
                        isSelected: selectedMethod == "Asphalt Institute",
                        onTap: () =>
                            setState(() => selectedMethod = "Asphalt Institute"),
                      ),
                      MethodButton(
                        method: "CTTP",
                        isSelected: selectedMethod == "CTTP",
                        onTap: () => setState(() => selectedMethod = "CTTP"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ]),
              ),
            ),
      
            if (selectedMethod == "CBR")
              SliverToBoxAdapter(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CBR(onValidated: _onValidated),
                    ),
                    SingleChildScrollView(
                      child: ResultPage(results: results),
                    ),
                  ],
                ),
              ),
          ],
        ),
      
        // 👇 BottomNavigationBar fixé en bas
        bottomNavigationBar: selectedMethod == "CBR"
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                  _scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut);
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.edit), label: 'Formulaire'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.stacked_bar_chart), label: 'Résultats'),
                ],
              )
            : null,
      ),
    );
  }
}
