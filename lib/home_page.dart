// import 'dart:io';

// import 'package:cunning_document_scanner/cunning_document_scanner.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// // class DocumentScannerApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(
// //           title: Text('Document Scanner'),
// //         ),
// //         body: Center(
// //           child: ElevatedButton(
// //             onPressed: () async {
// //               File? capturedImage = await CunningDocumentScanner.scanDocument();
// //               if (capturedImage == null) {
// //                 // User canceled the scanning process or there was an error.
// //                 return;
// //               }

// //               // Do something with the captured image, such as saving it to the gallery or processing it further.
// //             },
// //             child: Text('Capture Image'),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// class DocumentScannerScreen extends StatefulWidget {
//   @override
//   _DocumentScannerScreenState createState() => _DocumentScannerScreenState();
// }

// class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
//   File? _image;

//   Future<void> _captureImage() async {
//     final imagePicker = ImagePicker();
//     final image = await imagePicker.pickImage(source: ImageSource.camera);

//     if (image != null) {
//       final compressedImage = await _compressImage(File(image.path));
//       setState(() {
//         _image = compressedImage as File?;
//       });
//     }
//   }

//   Future<XFile?> _compressImage(File file) async {
//     final tempDir = await getTemporaryDirectory();
//     final targetPath = tempDir.path + '/${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 70,
//     );
//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Document Scanner App')),
//       body: Center(
//         child: _image == null
//             ? Text('No Image Selected')
//             : Image.file(_image!),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _captureImage,
//         child: Icon(Icons.camera_alt),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<File> _pictures = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _onPressed,
              child: const Text('Get and Resize Pictures'),
            ),
            _pictures.isNotEmpty
                ? Column(
                    children: _pictures.map((picture) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            picture,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> _onPressed() async {
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (!mounted) return;

      List<String> resizedPictures = [];
      for (var picture in pictures) {
        String? resizedPath = await resizeImage(picture);
        resizedPictures.add(resizedPath!);
      }

      setState(() {
        _pictures = resizedPictures.map((path) => File(path)).toList();
      });
      // ignore: empty_catches
    } catch (exception) {}
  }

  Future<String?> resizeImage(String imagePath) async {
    final compressedImagePath = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      imagePath.replaceAll('.jpg', '_compressed.jpg'),
      quality: 75,
    );
    return compressedImagePath?.path;
  }
}
