import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

Future<List<Uint8List>> splitImageFromMemory(
    Uint8List imageBytes, int rows, int cols) async {
  final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;

  int tileWidth = (image.width / cols).floor();
  int tileHeight = (image.height / rows).floor();

  List<Uint8List> tiles = [];
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final srcRect = Rect.fromLTWH(
          col * tileWidth.toDouble(),
          row * tileHeight.toDouble(),
          tileWidth.toDouble(),
          tileHeight.toDouble());
      final dstRect =
          Rect.fromLTWH(0, 0, tileWidth.toDouble(), tileHeight.toDouble());

      canvas.drawImageRect(image, srcRect, dstRect, Paint());
      final croppedImage =
          await recorder.endRecording().toImage(tileWidth, tileHeight);
      final byteData =
          await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      tiles.add(Uint8List.view(byteData!.buffer));
    }
  }

  return tiles;
}
