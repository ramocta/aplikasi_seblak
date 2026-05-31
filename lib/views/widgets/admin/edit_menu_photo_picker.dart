import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditMenuPhotoPicker extends StatelessWidget {
  final File? imageFile;
  final Uint8List? webImageBytes;
  final String? webImageName;
  final String gambarUrl;
  final VoidCallback onPickImage;

  const EditMenuPhotoPicker({
    super.key,
    required this.imageFile,
    required this.webImageBytes,
    required this.webImageName,
    required this.gambarUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          image: kIsWeb && webImageBytes != null
              ? DecorationImage(image: MemoryImage(webImageBytes!), fit: BoxFit.cover)
              : !kIsWeb && imageFile != null
                  ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                  : (gambarUrl.isNotEmpty && gambarUrl.startsWith('http'))
                      ? DecorationImage(image: NetworkImage(gambarUrl), fit: BoxFit.cover)
                      : null,
        ),
        child: webImageBytes == null && imageFile == null && (!gambarUrl.startsWith('http'))
            ? const Center(
                child: Icon(Icons.camera_alt, size: 40, color: Colors.grey),
              )
            : const Stack(
                children: [
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: Icon(Icons.edit, size: 16, color: Color(0xFFE64A19)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

