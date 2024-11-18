import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/image_picker.dart';
import '../../utils/image_processor.dart';
import '../widgets/game_grid.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<Uint8List> tiles = [];
  List<int> currentOrder = [];
  List<int> correctOrder = [];
  bool isLoading = false;
  String name = "Người chơi";
  int gridSize = 2; // Mặc định 2x2

  Timer? _timer;
  int _remainingTime = 60; // 60 giây để hoàn thành trò chơi

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('username') ?? 'Người chơi';
    });
  }

  Future<void> _loadFromGallery() async {
    setState(() => isLoading = true);
    try {
      final imageBytes = await pickImage(ImageSource.gallery);
      if (imageBytes != null) {
        final compressedBytes = await compressImage(imageBytes);
        final result = await processImage(compressedBytes, gridSize);
        setState(() {
          tiles = result.tiles;
          correctOrder = result.correctOrder;
          currentOrder = result.currentOrder..shuffle();
        });
        _startTimer();
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _showFailDialog();
      }
    });
  }

  void _swapTiles(int oldIndex, int newIndex) {
    setState(() {
      final temp = currentOrder[oldIndex];
      currentOrder[oldIndex] = currentOrder[newIndex];
      currentOrder[newIndex] = temp;
    });

    if (currentOrder.toString() == correctOrder.toString()) {
      _timer?.cancel();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Thành công!'),
        content: Text(
            'Bạn đã hoàn thành trò chơi trong ${60 - _remainingTime} giây!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                tiles.clear();
                currentOrder.clear();
                correctOrder.clear();
              });
            },
            child: const Text('Chơi lại'),
          ),
        ],
      ),
    );
  }

  void _showFailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Thất bại'),
        content: const Text('Thời gian đã hết, bạn chưa hoàn thành trò chơi.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                tiles.clear();
                currentOrder.clear();
                correctOrder.clear();
              });
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MinSnap: Xin chào $name!'),
        backgroundColor: const Color.fromRGBO(225, 179, 142, 100),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (tiles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '⏳ Thời gian còn lại: $_remainingTime giây',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // Khung hiển thị lưới cố định
                  AspectRatio(
                    aspectRatio: 1, // Lưới luôn là hình vuông
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: tiles.isEmpty
                          ? const Center(
                              child: Text(
                                "Chọn mức độ và ảnh để bắt đầu!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            )
                          : GameGrid(
                              tiles: tiles,
                              currentOrder: currentOrder,
                              swapTiles: _swapTiles,
                              gridSize: gridSize,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    value: gridSize,
                    items: const [
                      DropdownMenuItem(value: 2, child: Text("2x2 (Dễ)")),
                      DropdownMenuItem(
                          value: 3, child: Text("3x3 (Trung bình)")),
                      DropdownMenuItem(value: 4, child: Text("4x4 (Khó)")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          gridSize = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loadFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text(
                      "Chọn ảnh",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
