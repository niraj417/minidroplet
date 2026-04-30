// import 'dart:io';
// import 'dart:math';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdfrx/pdfrx.dart';
// import 'package:tinydroplets/common/widgets/loader.dart';
// import 'package:tinydroplets/core/utils/shared_pref.dart';
//
// class PdfViewerPage extends StatefulWidget {
//   final String pdfUrl;
//
//   const PdfViewerPage({super.key, required this.pdfUrl});
//
//   @override
//   State<PdfViewerPage> createState() => _PdfViewerPageState();
// }
//
// class _PdfViewerPageState extends State<PdfViewerPage> {
//   bool isLoading = true;
//   String? localFilePath;
//
//   final PdfViewerController _controller = PdfViewerController();
//
//   final bool isRightToLeft = false;
//   final bool useCoverPage = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _downloadAndSavePdf();
//   }
//
//   Future<void> _downloadAndSavePdf() async {
//     try {
//       final dir = await getApplicationDocumentsDirectory();
//       final filePath = '${dir.path}/ebook.pdf';
//
//       final response = await Dio().get(
//         widget.pdfUrl,
//         options: Options(responseType: ResponseType.bytes),
//       );
//
//       await File(filePath).writeAsBytes(response.data);
//
//       setState(() {
//         localFilePath = filePath;
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint('PDF download failed: $e');
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final initialPage = SharedPref.getInt('last_visited_page') ?? 1;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Guide Viewer')),
//       body: isLoading
//           ? const Loader()
//           : localFilePath == null
//           ? const Center(child: Text('Failed to load PDF'))
//           : PdfViewer.file(
//
//         localFilePath!,
//         controller: _controller,
//         params: PdfViewerParams(
//           //initialPage: initialPage,
//           layoutPages: _bookLayout,
//           onPageChanged: (page) {
//             SharedPref.setInt('last_visited_page', page!);
//           },
//         ),
//       ),
//     );
//   }
//
//   /// 📖 Horizontal book-style layout (NO vertical scrolling)
//   PdfPageLayout _bookLayout(
//       List<PdfPage> pages,
//       params,
//       ) {
//     final maxWidth =
//     pages.fold<double>(0, (w, p) => max(w, p.width));
//
//     final layouts = <Rect>[];
//     final offset = useCoverPage ? 1 : 0;
//
//     double y = params.margin;
//
//     for (int i = 0; i < pages.length; i++) {
//       final page = pages[i];
//       final pos = i + offset;
//
//       final isLeft = isRightToLeft ? (pos & 1) == 1 : (pos & 1) == 0;
//       final pairIndex = (pos ^ 1) - offset;
//
//       final height = (pairIndex >= 0 && pairIndex < pages.length)
//           ? max(page.height, pages[pairIndex].height)
//           : page.height;
//
//       layouts.add(
//         Rect.fromLTWH(
//           isLeft
//               ? maxWidth + params.margin - page.width
//               : params.margin * 2 + maxWidth,
//           y + (height - page.height) / 2,
//           page.width,
//           page.height,
//         ),
//       );
//
//       if (pos.isOdd || i + 1 == pages.length) {
//         y += height + params.margin;
//       }
//     }
//
//     return PdfPageLayout(
//       pageLayouts: layouts,
//       documentSize: Size(
//         (params.margin + maxWidth) * 2 + params.margin,
//         y,
//       ),
//     );
//   }
// }


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get_it/get_it.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/utils/shared_pref.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/network/api_controller.dart';
import '../../../../core/theme/theme_bloc/theme_bloc.dart';
import '../../../../core/theme/theme_bloc/theme_state.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerPage({super.key, required this.pdfUrl});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfViewerController _pdfViewerController;
  bool isLoading = true;
  int? currentPage;
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadSavedPage();
    _downloadAndSavePdf();
  }

  Future<void> _loadSavedPage() async {
    setState(() {
      currentPage = SharedPref.getInt('last_visited_page') ?? 1;
    });
  }

  Future<void> _saveCurrentPage(int page) async {
    await SharedPref.setInt('last_visited_page', page);
  }

  Future<void> _downloadAndSavePdf() async {
    Dio dio = Dio();
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/downloaded.pdf";

      final response = await dio.get(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.data);

        setState(() {
          localFilePath = filePath;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Guide Viewer",
          style: TextStyle(fontSize: 20),
        ),
        // actions: [
        //   if (!isLoading && localFilePath != null)
        //     Padding(
        //       padding: const EdgeInsets.only(right: 16.0),
        //       child: Center(
        //         child: Text(
        //           'Page ${_pdfViewerController.pageNumber} of ${_pdfViewerController.pageCount}',
        //           style: const TextStyle(fontSize: 16),
        //         ),
        //       ),
        //     ),
        // ],
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Loader()
          else if (localFilePath != null)
            SfPdfViewerTheme(
              data: SfPdfViewerThemeData(

                scrollHeadStyle: PdfScrollHeadStyle(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              child: SfPdfViewer.file(

                File(localFilePath!),
                controller: _pdfViewerController,

                // 🔑 Book-style reading
                pageLayoutMode: PdfPageLayoutMode.single,
                scrollDirection: PdfScrollDirection.horizontal,

                // Smooth snap behavior
                enableDoubleTapZooming: false,
                canShowScrollHead: false,
                canShowScrollStatus: false,

                // Keep UX clean
                enableTextSelection: true,

                onPageChanged: (PdfPageChangedDetails details) {
                  _saveCurrentPage(details.newPageNumber);
                },

                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  if (currentPage != null) {
                    _pdfViewerController.jumpToPage(currentPage!);
                  }
                },
              ),
            )
          else
            const Center(child: Text("Error loading PDF")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}
