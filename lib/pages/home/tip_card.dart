import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TipCard extends StatefulWidget {
  const TipCard({super.key});

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _currentIndex = 0;
  String _visibleText = "";
  double _opacity = 0.0;
  double _scale = 1.0; // ✅ effet visuel au clic

  final List<String> tips = [
    "La méthode CBR permet de déterminer l'épaisseur totale d'une chaussée à partir de la portance du sol et du trafic.",
    "Les ponts métalliques combinent résistance et légèreté, ce qui les rend adaptés aux grandes portées.",
    "Un bon drainage est essentiel pour prolonger la durée de vie des routes.",
    "Les poutres en béton précontraint supportent des charges plus importantes que les poutres classiques.",
    "Les chaussées souples s'adaptent mieux aux variations climatiques que les chaussées rigides.",
    "La méthode de dimensionnement des chaussées proposée par l'Asphalt Institute a été développée afin de remédier à certaines limites observées dans les méthodes de dimensionnement reposant uniquement sur l'indice CBR."
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _startTyping(tips[_currentIndex]); // ✅ premier texte dès le chargement
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTyping(String fullText) {
    _timer?.cancel();
    _visibleText = "";
    _opacity = 0.0;
    int i = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (i < fullText.length) {
        setState(() {
          _visibleText += fullText[i];
          _opacity = 1.0;
        });
        i++;
      } else {
        timer.cancel();
      }
    });
  }

  void _nextTip() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % tips.length;
      _scale = 0.95; // ✅ petit zoom au clic
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _scale = 1.0; // ✅ retour à la taille normale
      });
    });

    _controller.reset();
    _controller.forward();
    _startTyping(tips[_currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextTip,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Lottie.asset(
                  'lib/assets/lottie/anime7ideaemoji.json',
                  height: 50,
                  width: 50,
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                    _controller.forward(); // ✅ démarre dès que la durée est connue
                  },
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LE SAVIEZ-VOUS ?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ✅ Stack pour réserver la place et superposer le texte progressif
                      Stack(
                        children: [
                          Opacity(
                            opacity: 0.0,
                            child: Text(
                              tips[_currentIndex],
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: _opacity,
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              _visibleText,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
