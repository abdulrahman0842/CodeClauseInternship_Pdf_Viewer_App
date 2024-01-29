import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_view/PdfDisplay.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF_Viewer',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          elevation: 0,
          color: Colors.teal,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black45),
      ),
      home: const PdfList(),
    );
  }
}

class PdfList extends StatefulWidget {
  const PdfList({super.key});
  @override
  State<PdfList> createState() => _PdfListState();
}

class _PdfListState extends State<PdfList> {
  List<File> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _loadPDFs();
  }

  Future<void> _loadPDFs() async {
    var permission = await Permission.manageExternalStorage.request();

    if (permission.isGranted) {
      Directory externalDir = Directory('/storage/emulated/0/');
      List<File> pdfFiles = [];

      _findPDFs(externalDir, pdfFiles);

      setState(() {
        this.pdfFiles = pdfFiles;
      });
    } else if (permission.isPermanentlyDenied) {
      // Handle permanently denied
      openAppSettings();
    } else {
      // Handle other cases of denied
      print('Permission Not Granted');
    }
  }
  
  void _findPDFs(Directory directory, List<File> pdfFiles) {
    try {
      List<FileSystemEntity> files = directory.listSync();

      for (FileSystemEntity file in files) {
        if (file is File && file.path.endsWith('.pdf')) {
          pdfFiles.add(file);
        } else if (file is Directory) {
          // Recursive call for subdirectories
          _findPDFs(file, pdfFiles);
        }
      }
    } catch (e) {
      print('Exception while searching for PDFs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 15, left: 4, right: 4),
        child: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              leading:
              Image.asset('assets/icon_pdf.png', height: 35, width: 35),
              title: Text(pdfFiles[index].path.split('/').last),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfDisplay(pdfFile: pdfFiles[index]),
                  ),
                );
              },
            );
          },
          itemCount: pdfFiles.length,
        ),
      ),
    );
  }
}
