import 'dart:typed_data';

import 'package:flutter/material.dart';

class GameGrid extends StatelessWidget {
  final List<Uint8List> tiles;
  final List<int> currentOrder;
  final Function(int, int) swapTiles;
  final int gridSize;

  const GameGrid({
    super.key,
    required this.tiles,
    required this.currentOrder,
    required this.swapTiles,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Không cuộn lưới
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize, // Số cột tùy thuộc vào mức độ khó
        crossAxisSpacing: 2, // Khoảng cách ngang giữa các ô
        mainAxisSpacing: 2, // Khoảng cách dọc giữa các ô
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tileIndex = currentOrder[index];
        return DragTarget<int>(
          onWillAccept: (data) => true,
          onAccept: (data) {
            final oldIndex = currentOrder.indexOf(data);
            swapTiles(oldIndex, index);
          },
          builder: (context, candidateData, rejectedData) {
            return Draggable<int>(
              data: tileIndex,
              feedback: Image.memory(
                tiles[tileIndex],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              childWhenDragging: Container(color: Colors.grey),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                child: Image.memory(
                  tiles[tileIndex],
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
