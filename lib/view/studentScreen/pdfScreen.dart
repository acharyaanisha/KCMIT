import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';


class PDFScreen extends StatelessWidget {
  final String filePath;
  final String resourceName;

  const PDFScreen(this.filePath, this.resourceName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Opening PDF from file path: $filePath");

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            title: Text(resourceName),
          ),
        ),
      ),
      body: PDFView(
        filePath: filePath,
        onError: (error) {
          print("PDFView Error: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error displaying PDF')),
          );
        },
        onPageError: (page, error) {
          print("PDF Page Error on page $page: $error");
        },
      ),
    );
  }
}
