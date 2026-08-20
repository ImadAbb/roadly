import 'package:flutter/material.dart';

class TabOptionsWidget extends StatefulWidget {
  final List<String> options;
  final List<IconData> icons;
  final Function(int) onTabSelected;

  const TabOptionsWidget({
    super.key,
    required this.options,
    required this.icons,
    required this.onTabSelected,
  }) : assert(options.length == icons.length);

  @override
  State<TabOptionsWidget> createState() => _TabOptionsWidgetState();
}

class _TabOptionsWidgetState extends State<TabOptionsWidget> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 10, 6, 6),

      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD7DFEC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      clipBehavior: Clip.antiAlias,

      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),

        child: Row(
          children: [
            ...List.generate(
              widget.options.length,
              (index) {
                final bool isSelected = selectedIndex == index;

                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (selectedIndex == index) return;

                        setState(() {
                          selectedIndex = index;
                        });

                        widget.onTabSelected(index);
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,

                        // AVANT : 125
                        width: 112,

                        // AVANT : 10 / 7
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),

                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,

                          borderRadius: BorderRadius.circular(9),

                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.18),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              // AVANT : padding 5
                              padding: const EdgeInsets.all(4),

                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : const Color(0xFFDCE5F3),
                                shape: BoxShape.circle,
                              ),

                              child: Icon(
                                widget.icons[index],

                                // AVANT : 16
                                size: 14,

                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF526174),
                              ),
                            ),

                            // AVANT : 7
                            const SizedBox(width: 5),

                            Text(
                              widget.options[index],

                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF526174),

                                // AVANT : 13
                                fontSize: 12,

                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (index != widget.options.length - 1)
                      const SizedBox(width: 3),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}