import 'package:flutter/material.dart';
import 'package:roadly/assets/themes/colors.dart';
import 'package:roadly/pages/modules/route/asphalt_institute/asphalt_institute.dart';
import 'package:roadly/pages/modules/route/cbr/cbr.dart';

class ModuleRoute extends StatefulWidget {
  const ModuleRoute({super.key});

  @override
  State<ModuleRoute> createState() => _ModuleRouteState();
}

class _ModuleRouteState extends State<ModuleRoute> {
  String? selectedMethod;
  bool _showHeader = true;

  final ScrollController scrollController = ScrollController();

  bool get _hasSelectedMethod => selectedMethod != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoadlyColors.backgroundLight,

      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: scrollController,
        slivers: [
          /// HEADER
          SliverAppBar(
            backgroundColor: const Color(0xFF42A5F5),
            elevation: 0,
            expandedHeight: _showHeader ? 220 : 0,
            floating: false,
            pinned: true,
            snap: false,
            toolbarHeight: _showHeader ? 56 : 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _showHeader
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "MODULE ROUTE",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            "Dimensionnement\nDes Chaussées",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            "Choisissez une méthode de calcul",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          /// CHOIX MÉTHODE
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: _showHeader
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(child: _methodCard("CBR", Icons.bar_chart)),

                          const SizedBox(width: 12),

                          Expanded(child: _methodCard("AI", Icons.layers)),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _methodCard("CTTP", Icons.architecture),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          if (_hasSelectedMethod)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showHeader = !_showHeader;
                  });
                  scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  height: 24,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Icon(
                    _showHeader
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),

          if (selectedMethod == "CBR") const SliverFillRemaining(child: CBR()),

          if (selectedMethod == "AI")
            const SliverFillRemaining(child: AsphaltInstute()),
        ],
      ),
    );
  }

  Widget _methodCard(String method, IconData icon) {
    final selected = selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
          _showHeader = false;
        });
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          color: selected ? Colors.blue.withValues(alpha: .1) : Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
          ),
        ),

        child: Column(
          children: [
            Icon(icon),

            const SizedBox(height: 8),

            Text(method, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
