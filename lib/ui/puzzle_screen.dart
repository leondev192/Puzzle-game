// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// import '../utils/image_utils.dart';
// import '../widgets/puzzle_tile.dart';
//
// class PuzzleScreen extends StatefulWidget {
//   final File image;
//
//   const PuzzleScreen({Key? key, required this.image}) : super(key: key);
//
//   @override
//   _PuzzleScreenState createState() => _PuzzleScreenState();
// }
//
// class _PuzzleScreenState extends State<PuzzleScreen> {
//   late List<Uint8List> tiles;
//   late List<int> correctOrder;
//   late List<int> currentOrder;
//   int moves = 0;
//   int timeLeft = 300; // 5 phút
//   Timer? timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePuzzle();
//     _startTimer();
//   }
//
//   Future<void> _initializePuzzle() async {
//     tiles = await splitImage(widget.image, 3, 3); // Chia ảnh thành 3x3
//     correctOrder = List.generate(tiles.length, (index) => index);
//     currentOrder = List.from(correctOrder)..shuffle(); // Xáo trộn vị trí
//     setState(() {});
//   }
//
//   void _startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (timeLeft > 0) {
//         setState(() {
//           timeLeft--;
//         });
//       } else {
//         timer.cancel();
//         _showGameOverDialog();
//       }
//     });
//   }
//
//   void _checkSolution() {
//     if (listEquals(currentOrder, correctOrder)) {
//       timer?.cancel();
//       _showWinDialog();
//     } else {
//       _showTryAgainDialog();
//     }
//   }
//
//   void _showWinDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Congratulations!'),
//         content: Text('You completed the puzzle in $moves moves!'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).pop(); // Quay lại màn hình chính
//             },
//             child: const Text('Play Again'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showTryAgainDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Try Again!'),
//         content: const Text('The puzzle is not completed correctly.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showGameOverDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Game Over!'),
//         content: const Text('Time is up!'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).pop(); // Quay lại màn hình chính
//             },
//             child: const Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double tileSize =
//         MediaQuery.of(context).size.width / 4; // Kích thước mỗi mảnh ghép
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Puzzle Game'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Moves: $moves', style: const TextStyle(fontSize: 18)),
//                 Text(
//                     'Time: ${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}',
//                     style: const TextStyle(fontSize: 18)),
//               ],
//             ),
//           ),
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 mainAxisSpacing: 8,
//                 crossAxisSpacing: 8,
//               ),
//               itemCount: tiles.length,
//               itemBuilder: (context, index) {
//                 return Draggable<int>(
//                   data: currentOrder[index],
//                   feedback: PuzzleTile(
//                     imageData: tiles[currentOrder[index]],
//                     isCorrect: currentOrder[index] == correctOrder[index],
//                     size: tileSize,
//                   ),
//                   child: DragTarget<int>(
//                     builder: (context, candidateData, rejectedData) {
//                       return PuzzleTile(
//                         imageData: tiles[currentOrder[index]],
//                         isCorrect: currentOrder[index] == correctOrder[index],
//                         size: tileSize,
//                       );
//                     },
//                     onAcceptWithDetails: (details) {
//                       setState(() {
//                         int oldIndex = currentOrder.indexOf(details.data!);
//                         currentOrder[oldIndex] = currentOrder[index];
//                         currentOrder[index] = details.data!;
//                         moves++;
//                       });
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: _checkSolution,
//               child: const Text('Check Solution'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }
// }
