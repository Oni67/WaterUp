import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: const Color.fromARGB(255, 255, 255, 255),
      color: const Color.fromARGB(255, 57, 57, 57),
      onPressed: onPressed,
      tooltip: 'Action',
      icon: const Icon(Icons.arrow_back),
    );
  }
}
