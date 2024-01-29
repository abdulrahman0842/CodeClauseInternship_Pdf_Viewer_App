import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfDisplay extends StatefulWidget {
  final File pdfFile;
  const PdfDisplay({super.key, required this.pdfFile});

  @override
  State<PdfDisplay> createState() => _PdfDisplayState();
}

class _PdfDisplayState extends State<PdfDisplay> {
  TextEditingController pageNumberController = TextEditingController();
  late PdfControllerPinch pdfControllerPinch;
  int totalPage = 0, currentPage = 1;
  @override
  void initState() {
    super.initState();
    try {
      pdfControllerPinch = PdfControllerPinch(
          document: PdfDocument.openFile(widget.pdfFile.path));
    } catch (e) {
      print('Exception:-> $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PDF Viewer'),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 1,
                        child: Text('Go To Page'),
                      )
                    ],
                elevation: 2,
                onSelected: (value) {
                  jumpToPage();
                })
          ],
        ),
        body: _buildUI());
  }

  Widget _buildUI() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  pdfControllerPinch.jumpToPage(0);
                  setState(() {
                    currentPage = 1;
                  });
                },
                icon: const Icon(Icons.home_outlined)),
            Text(
              'Total Pages: $totalPage',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Current Page: $currentPage',
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          ],
        ),
        _pdfView(),
      ],
    );
  }

  Widget _pdfView() {
    return Expanded(
        child: PdfViewPinch(
      controller: pdfControllerPinch,
      onDocumentLoaded: (doc) {
        setState(() {
          totalPage = doc.pagesCount;
        });
      },
      onPageChanged: (page) {
        setState(() {
          currentPage = page;
        });
      },
    ));
  }

  void jumpToPage() async {
    return showDialog(
      context: context,
      builder: (BuildContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: pageNumberController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    label: Text('Jump to page')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      String pageNumber = pageNumberController.text;
                      int jumpPage = int.parse(pageNumber);
                      pdfControllerPinch.jumpToPage(jumpPage);
                      pageNumberController.clear();
                      currentPage = jumpPage;
                      Navigator.pop(context);
                    });
                  },
                  child: const Text('Jump To...'))
            ],
          ),
        );
      },
    );
  }
}
