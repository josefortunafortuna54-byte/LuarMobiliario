import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_palette.dart';

class XFileThumbnail extends StatelessWidget {
  final XFile file;

  const XFileThumbnail({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }
        if (snapshot.hasError) {
          return Container(
            color: palette.surfaceAlt,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: palette.textMuted,
            ),
          );
        }
        return Container(
          color: palette.border,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}