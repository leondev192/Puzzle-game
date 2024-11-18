import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker _picker = ImagePicker();
  final XFile? photo = await _picker.pickImage(source: source);
  if (photo != null) {
    return await photo.readAsBytes();
  }
  return null;
}
