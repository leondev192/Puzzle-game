import 'dart:typed_data';

import 'package:flutter/material.dart';

class PuzzleTile extends StatelessWidget {
  final Uint8List imageData;
  final bool isCorrect;
  final double size;

  const PuzzleTile({
    Key? key,
    required this.imageData,
    required this.isCorrect,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          imageData,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
