import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PuzzleGame(),
    );
  }
}

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<Uint8List> tiles = [];
  List<int> currentOrder = [];
  List<int> correctOrder = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  // Xử lý cắt ảnh
  Future<void> _processImage(Uint8List imageBytes) async {
    try {
      final img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception("Không thể xử lý ảnh");

      const int rows = 2, cols = 2;
      final int tileWidth = (image.width / cols).floor();
      final int tileHeight = (image.height / rows).floor();

      tiles.clear();
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          final img.Image tile = img.copyCrop(
            image,
            x: j * tileWidth,
            y: i * tileHeight,
            width: tileWidth,
            height: tileHeight,
          );
          tiles.add(Uint8List.fromList(img.encodePng(tile)));
        }
      }

      correctOrder = List.generate(tiles.length, (index) => index);
      currentOrder = List.from(correctOrder)..shuffle();

      setState(() {});
    } catch (e) {
      print("Lỗi khi xử lý ảnh: $e");
    }
  }

// Hàm nén ảnh
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      // Giảm kích thước và chất lượng ảnh
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 800, // Chiều rộng tối thiểu sau khi nén
        minHeight: 800, // Chiều cao tối thiểu sau khi nén
        quality: 85, // Chất lượng ảnh (1-100)
      );

      if (compressedBytes == null) throw Exception("Không thể nén ảnh");
      return compressedBytes;
    } catch (e) {
      print("Lỗi khi nén ảnh: $e");
      rethrow;
    }
  }

  Future<void> _loadFromCamera() async {
    try {
      setState(() {
        isLoading = true;
      });
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final Uint8List originalBytes = await photo.readAsBytes();
        final Uint8List compressedBytes = await _compressImage(originalBytes);
        await _processImage(compressedBytes);
      }
    } catch (e) {
      print("Lỗi khi chụp ảnh: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFromGallery() async {
    try {
      setState(() {
        isLoading = true;
      });
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        final Uint8List originalBytes = await photo.readAsBytes();
        final Uint8List compressedBytes = await _compressImage(originalBytes);
        await _processImage(compressedBytes);
      }
    } catch (e) {
      print("Lỗi khi chọn ảnh: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hoán đổi vị trí 2 mảnh ghép
  void _swapTiles(int oldIndex, int newIndex) {
    setState(() {
      final temp = currentOrder[oldIndex];
      currentOrder[oldIndex] = currentOrder[newIndex];
      currentOrder[newIndex] = temp;
    });

    if (currentOrder.toString() == correctOrder.toString()) {
      _showWinDialog();
    }
  }

  // Hiển thị thông báo chiến thắng
  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thành công'),
        content: const Text('Bạn đã sắp xếp hoàn thành '),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                tiles.clear(); // Xóa trạng thái trò chơi
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game sắp xếp '),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Đang xử lý ảnh, vui lòng chờ..."),
                ],
              ),
            )
          : tiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Chọn nguồn ảnh từ?",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Chụp ảnh"),
                        onPressed: _loadFromCamera,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo),
                        label: const Text("Thư viện"),
                        onPressed: _loadFromGallery,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: tiles.length,
                  itemBuilder: (context, index) {
                    final int tileIndex = currentOrder[index];
                    return DragTarget<int>(
                      onWillAccept: (data) => true,
                      onAccept: (data) {
                        final oldIndex = currentOrder.indexOf(data);
                        _swapTiles(oldIndex, index);
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
                          childWhenDragging: Container(
                            color: Colors.grey,
                          ),
                          child: Image.memory(
                            tiles[tileIndex],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
