import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_colors.dart';

class XFileThumbnail extends StatelessWidget {
  final XFile file;

  const XFileThumbnail({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }
        if (snapshot.hasError) {
          return Container(
            color: AppColors.gray200,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.gray400,
            ),
          );
        }
        return Container(
          color: AppColors.gray100,
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