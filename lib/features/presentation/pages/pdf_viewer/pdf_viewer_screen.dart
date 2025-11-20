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
                initialPageNumber: currentPage ?? 0,
                onPageChanged: (PdfPageChangedDetails details) {
                  setState(() {
                    _saveCurrentPage(details.newPageNumber);
                  });
                },
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  if (currentPage != null) {
                    _pdfViewerController.jumpToPage(currentPage!);
                  }
                },
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableDoubleTapZooming: true,
                enableTextSelection: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                scrollDirection: PdfScrollDirection.vertical,
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


//
//
// class PdfViewerPage extends StatefulWidget {
//   final String pdfUrl;
//   final String? title;
//
//   const PdfViewerPage({
//     super.key,
//     required this.pdfUrl,
//     this.title = "Guide Viewer"
//   });
//
//   @override
//   State<PdfViewerPage> createState() => _PdfViewerPageState();
// }
//
// class _PdfViewerPageState extends State<PdfViewerPage> with WidgetsBindingObserver {
//   late PdfViewerController _pdfViewerController;
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
//
//   bool _isLoading = true;
//   bool _hasError = false;
//   String? _errorMessage;
//   String? _localFilePath;
//   int? _currentPage;
//   double _downloadProgress = 0;
//   bool _isDownloading = false;
//   CancelToken? _cancelToken;
//
//   // Cache settings
//   final _cacheKey = 'pdf_cache';
//   final _cacheMaxAge = const Duration(days: 7);
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _pdfViewerController = PdfViewerController();
//     _loadSavedPage();
//     _loadPdf();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Save page when app goes to background
//     if (state == AppLifecycleState.paused) {
//       _saveCurrentPage(_pdfViewerController.pageNumber);
//     }
//   }
//
//   Future<void> _loadSavedPage() async {
//     final pdfName = Uri.parse(widget.pdfUrl).pathSegments.last;
//     final pageKey = '${pdfName}_last_page';
//     setState(() {
//       _currentPage = SharedPref.getInt(pageKey) ?? 1;
//     });
//   }
//
//   Future<void> _saveCurrentPage(int page) async {
//     final pdfName = Uri.parse(widget.pdfUrl).pathSegments.last;
//     final pageKey = '${pdfName}_last_page';
//     await SharedPref.setInt(pageKey, page);
//   }
//
//   Future<void> _loadPdf() async {
//     try {
//       // First check if the file is in the cache
//       final fileInfo = await DefaultCacheManager().getFileFromCache(widget.pdfUrl);
//
//       if (fileInfo != null && fileInfo.file.existsSync()) {
//         setState(() {
//           _localFilePath = fileInfo.file.path;
//           _isLoading = false;
//         });
//         return;
//       }
//
//       // If not in cache, download it
//       await _downloadAndSavePdf();
//     } catch (e) {
//       _handleError('Failed to load PDF: $e');
//     }
//   }
//
//   Future<void> _downloadAndSavePdf() async {
//     _cancelToken = CancelToken();
//     setState(() {
//       _isDownloading = true;
//       _downloadProgress = 0;
//     });
//
//     try {
//       // Download with progress tracking
//       final file = await DefaultCacheManager().downloadFile(
//         widget.pdfUrl,
//         key: widget.pdfUrl,
//         authHeaders: {}, // Add auth headers if needed
//         maxAgeCacheObject: _cacheMaxAge,
//       );
//
//       setState(() {
//         _localFilePath = file.file.path;
//         _isDownloading = false;
//         _isLoading = false;
//       });
//
//     } catch (e) {
//       if (_cancelToken?.isCancelled ?? false) {
//         _handleError('Download cancelled');
//       } else {
//         _handleError('Error downloading PDF: $e');
//       }
//     }
//   }
//
//   void _handleError(String message) {
//     print(message);
//     setState(() {
//       _hasError = true;
//       _errorMessage = message;
//       _isLoading = false;
//       _isDownloading = false;
//     });
//   }
//
//   Future<void> _clearCache() async {
//     await DefaultCacheManager().emptyCache();
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Cache cleared'))
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.title ?? "Guide Viewer",
//           style: const TextStyle(fontSize: 20),
//         ),
//         actions: [
//           if (!_isLoading && _localFilePath != null)
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () {
//                 _clearCache();
//                 setState(() {
//                   _isLoading = true;
//                   _localFilePath = null;
//                 });
//                 _loadPdf();
//               },
//             ),
//           if (!_isLoading && _localFilePath != null)
//             Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Center(
//                 child: Text(
//                   'Page ${_pdfViewerController.pageNumber} of ${_pdfViewerController.pageCount}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           if (_isLoading)
//             _buildLoadingWidget()
//           else if (_hasError)
//             _buildErrorWidget()
//           else if (_localFilePath != null)
//               _buildPdfViewer()
//             else
//               const Center(child: Text("Unable to load PDF")),
//         ],
//       ),
//       floatingActionButton: _buildNavigationButtons(),
//     );
//   }
//
//   Widget _buildLoadingWidget() {
//     if (_isDownloading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(value: _downloadProgress > 0 ? _downloadProgress : null),
//             const SizedBox(height: 16),
//             Text('Downloading PDF... ${(_downloadProgress * 100).toStringAsFixed(0)}%'),
//             const SizedBox(height: 8),
//             TextButton(
//               onPressed: () {
//                 _cancelToken?.cancel();
//                 setState(() {
//                   _isLoading = false;
//                   _isDownloading = false;
//                   _hasError = true;
//                   _errorMessage = 'Download cancelled';
//                 });
//               },
//               child: const Text('Cancel'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return const Loader();
//     }
//   }
//
//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 60, color: Colors.red),
//           const SizedBox(height: 16),
//           Text(_errorMessage ?? 'Error loading PDF', textAlign: TextAlign.center),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _isLoading = true;
//                 _hasError = false;
//               });
//               _loadPdf();
//             },
//             child: const Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPdfViewer() {
//     return SfPdfViewerTheme(
//       data: SfPdfViewerThemeData(
//         scrollHeadStyle: PdfScrollHeadStyle(
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         ),
//       ),
//       child: SfPdfViewer.file(
//         File(_localFilePath!),
//         key: _pdfViewerKey,
//         controller: _pdfViewerController,
//         initialPageNumber: _currentPage ?? 1,
//         canShowScrollHead: true,
//         canShowScrollStatus: true,
//         enableDoubleTapZooming: true,
//         enableTextSelection: true,
//         pageLayoutMode: PdfPageLayoutMode.continuous,
//         scrollDirection: PdfScrollDirection.vertical,
//         onPageChanged: (PdfPageChangedDetails details) {
//           setState(() {
//             _saveCurrentPage(details.newPageNumber);
//           });
//         },
//         onDocumentLoaded: (PdfDocumentLoadedDetails details) {
//           if (_currentPage != null) {
//             _pdfViewerController.jumpToPage(_currentPage!);
//           }
//         },
//         // Performance optimizations
//         enableProgressiveLoading: true,
//         canShowPaginationDialog: true,
//         pageSpacing: 0,
//         interactionMode: PdfInteractionMode.pan,
//       ),
//     );
//   }
//
//   Widget? _buildNavigationButtons() {
//     if (_isLoading || _hasError || _localFilePath == null) return null;
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           FloatingActionButton(
//             heroTag: 'prev',
//             mini: true,
//             onPressed: _pdfViewerController.pageNumber > 1
//                 ? () => _pdfViewerController.previousPage()
//                 : null,
//             child: const Icon(Icons.navigate_before),
//           ),
//           const SizedBox(width: 16),
//           FloatingActionButton(
//             heroTag: 'next',
//             mini: true,
//             onPressed: _pdfViewerController.pageNumber < _pdfViewerController.pageCount
//                 ? () => _pdfViewerController.nextPage()
//                 : null,
//             child: const Icon(Icons.navigate_after),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _cancelToken?.cancel();
//     _pdfViewerController.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
// }