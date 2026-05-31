import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddMenuPhotoPicker extends StatelessWidget {
  final File? imageFile;
  final Uint8List? webImageBytes;
  final String? webImageName;
  final VoidCallback onPickImage;

  const AddMenuPhotoPicker({
    super.key,
    required this.imageFile,
    required this.webImageBytes,
    required this.webImageName,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0).withOpacity(0.6)),
          image: kIsWeb && webImageBytes != null
              ? DecorationImage(image: MemoryImage(webImageBytes!), fit: BoxFit.cover)
              : !kIsWeb && imageFile != null
                  ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                  : null,
        ),
        child: webImageBytes == null && imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    size: 38,
                    color: Color(0xFFE64A19),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to upload image',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : const Stack(
                children: [
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFFE64A19),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

