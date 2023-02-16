import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Previewpage extends StatelessWidget {
  final pw.Document doc;

  const Previewpage({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        centerTitle: true,
        title: const Text("Tag Preview"),
      ),
      body: PdfPreview(
        build: (format) => doc.save(),
        allowPrinting: true,
        allowSharing: false,
          canChangePageFormat: false,
          canChangeOrientation: false,
        canDebug: false,
        initialPageFormat: const PdfPageFormat(38.1 * (72.0/25.4), double.infinity, marginAll: 0),
        pdfFileName: "tag.pdf",
      ),
    );
  }
}