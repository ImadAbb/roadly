import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const MyButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 233, 149, 143),
          borderRadius: BorderRadius.circular(40),
        ),
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //text
            Text(text, style: TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(width: 10),
            //icon
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class MyCheckBoxButton extends StatefulWidget {
  final String text;
  const MyCheckBoxButton({super.key, required this.text});

  @override
  State<MyCheckBoxButton> createState() => _MyCheckBoxButtonState();
}

class _MyCheckBoxButtonState extends State<MyCheckBoxButton> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked; // bascule l'état
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isChecked
              ? const Color.fromARGB(255, 191, 54, 12) // rouge foncé si coché
              : const Color.fromARGB(255, 233, 149, 143), // rose clair si décoché
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(width: 10),
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class MethodButton extends StatelessWidget {
  final String method;
  final bool isSelected;
  final VoidCallback onTap;

  const MethodButton({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 191, 54, 12) // sélectionné
              : const Color.fromARGB(255, 233, 149, 143), // non sélectionné
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Text(
              method,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}