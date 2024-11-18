import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class FillInformation extends StatefulWidget {
  const FillInformation({super.key});

  @override
  State<FillInformation> createState() => _FillInformationState();
}

class _FillInformationState extends State<FillInformation> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveNameAndNavigate() async {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên')),
      );
      return;
    }

    // Lưu tên vào SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);

    // Điều hướng đến màn hình Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PuzzleGame()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Nhập Thông Tin'),
        ),
        backgroundColor: Color.fromRGBO(225, 179, 142, 100),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Chào mừng bạn đến với MindSnap!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Vui lòng Tên của bạn',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(225, 179, 142, 100),
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(225, 179, 142, 100),
                    width: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNameAndNavigate,
              child: const Text('Bắt đầu'),
            ),
          ],
        ),
      ),
    );
  }
}
