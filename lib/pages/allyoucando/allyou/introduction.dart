import 'package:flutter/material.dart';
import 'package:roadly/pages/allyoucando/allyou/pageone.dart';
import 'package:roadly/pages/allyoucando/allyou/pagethree.dart';
import 'package:roadly/pages/allyoucando/allyou/pagetwo.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  final PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [         

          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [PageOne(), PageTwo(), PageThree()],
          ),

          Container(
            alignment: Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 70,
                  child: GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(2);
                    },
                    child: Text("Passer"),
                  ),
                ),

                SmoothPageIndicator(controller: _controller, count: 3),

                SizedBox(
                  width: 70, // 👈 largeur fixe
                  child: onLastPage
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text("Terminer"),
                        )
                      : GestureDetector(
                          onTap: () {
                            _controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Text("Suivant"),
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.close, size: 30, color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }
}
