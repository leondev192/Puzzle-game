import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

class ProcessedImage {
  final List<Uint8List> tiles;
  final List<int> correctOrder;
  final List<int> currentOrder;

  ProcessedImage(this.tiles, this.correctOrder, this.currentOrder);
}

Future<ProcessedImage> processImage(Uint8List imageBytes, int gridSize) async {
  final img.Image? image = img.decodeImage(imageBytes);
  if (image == null) throw Exception("Không thể xử lý ảnh");

  // Đảm bảo ảnh đầu vào là hình vuông
  final int sideLength =
      image.width < image.height ? image.width : image.height;
  final img.Image squareImage = img.copyCrop(
    image,
    x: (image.width - sideLength) ~/ 2, // Cắt ở giữa (chiều ngang)
    y: (image.height - sideLength) ~/ 2, // Cắt ở giữa (chiều dọc)
    width: sideLength,
    height: sideLength,
  );

  // Tính toán kích thước từng phần
  final int tileWidth = (squareImage.width / gridSize).floor();
  final int tileHeight = (squareImage.height / gridSize).floor();

  // Cắt ảnh thành các mảnh nhỏ
  final List<Uint8List> tiles = [];
  for (int i = 0; i < gridSize; i++) {
    for (int j = 0; j < gridSize; j++) {
      final img.Image tile = img.copyCrop(
        squareImage,
        x: j * tileWidth,
        y: i * tileHeight,
        width: tileWidth,
        height: tileHeight,
      );
      tiles.add(Uint8List.fromList(img.encodePng(tile)));
    }
  }

  final correctOrder = List.generate(tiles.length, (index) => index);
  final currentOrder = List<int>.from(correctOrder);

  return ProcessedImage(tiles, correctOrder, currentOrder);
}

Future<Uint8List> compressImage(Uint8List imageBytes) async {
  final Uint8List? compressedBytes =
      await FlutterImageCompress.compressWithList(
    imageBytes,
    minWidth: 800,
    minHeight: 800,
    quality: 85,
  );

  if (compressedBytes == null) throw Exception("Không thể nén ảnh");
  return compressedBytes;
}
