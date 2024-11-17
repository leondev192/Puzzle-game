// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// import 'puzzle_screen.dart';
//
// class ImageUploadScreen extends StatefulWidget {
//   const ImageUploadScreen({Key? key}) : super(key: key);
//
//   @override
//   _ImageUploadScreenState createState() => _ImageUploadScreenState();
// }
//
// class _ImageUploadScreenState extends State<ImageUploadScreen> {
//   File? _selectedImage;
//
//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload an Image'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _selectedImage != null
//                 ? Image.file(_selectedImage!,
//                     width: 200, height: 200, fit: BoxFit.cover)
//                 : const Text('No image selected.'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: const Text('Pick Image'),
//             ),
//             const SizedBox(height: 20),
//             _selectedImage != null
//                 ? ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               PuzzleScreen(image: _selectedImage!),
//                         ),
//                       );
//                     },
//                     child: const Text('Start Puzzle'),
//                   )
//                 : Container(),
//           ],
//         ),
//       ),
//     );
//   }
// }
