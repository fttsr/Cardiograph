import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ResultPdfPreviewScreen extends StatelessWidget {
  const ResultPdfPreviewScreen({
    super.key,
    required this.path,
    required this.name,
  });

  final String path;
  final String name;

  @override
  Widget build(BuildContext context) {
    final file = File(path);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: PdfPreview(
        canChangeOrientation: false,
        canChangePageFormat: false,
        build: (_) => file.readAsBytes(),
      ),
    );
  }
}
