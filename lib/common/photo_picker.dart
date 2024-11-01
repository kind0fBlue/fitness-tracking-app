// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class PhotoPicker extends StatefulWidget {
//   @override
//   _PhotoPickerState createState() => _PhotoPickerState();
// }
//
// class _PhotoPickerState extends State<PhotoPicker> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//
//   // Method to pick an image from the camera or gallery
//   Future<void> _getImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);  // Store the image file
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Upload Food Photo")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _image == null
//                 ? Text("No image selected.")
//                 : Image.file(_image!),
//             ElevatedButton(
//               onPressed: () => _getImage(ImageSource.camera),
//               child: Text("Take Photo"),
//             ),
//             ElevatedButton(
//               onPressed: () => _getImage(ImageSource.gallery),
//               child: Text("Select from Gallery"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatefulWidget {
  const PhotoPicker({super.key});

  @override
  _PhotoPickerState createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Method to pick an image from the camera or gallery
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Store the image file
      });

      // Return the image to the previous screen
      Navigator.of(context).pop(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Food Photo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? const Text("No image selected.")
                : Image.file(_image!),
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.camera),
              child: const Text("Take Photo"),
            ),
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.gallery),
              child: const Text("Select from Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
