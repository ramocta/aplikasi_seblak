import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditToppingPhotoPicker extends StatelessWidget {
  final File? imageFile;
  final Uint8List? webImageBytes;
  final String? webImageName;
  final String gambarUrl;
  final VoidCallback onPickImage;

  const EditToppingPhotoPicker({
    super.key,
    required this.imageFile,
    required this.webImageBytes,
    required this.webImageName,
    required this.gambarUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNetwork = gambarUrl.isNotEmpty && gambarUrl.startsWith('http');
    final bool hasWeb = kIsWeb && webImageBytes != null;
    final bool hasFile = !kIsWeb && imageFile != null;

    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          image: hasWeb
              ? DecorationImage(image: MemoryImage(webImageBytes!), fit: BoxFit.cover)
              : hasFile
                  ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                  : hasNetwork
                      ? DecorationImage(image: NetworkImage(gambarUrl), fit: BoxFit.cover)
                      : null,
        ),
        child: (!hasWeb && !hasFile && !hasNetwork)
            ? const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey))
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

