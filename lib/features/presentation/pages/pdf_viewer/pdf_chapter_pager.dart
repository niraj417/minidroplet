import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../ebook_page/model/purchased_ebook_model.dart';

class PdfChapterPager extends StatefulWidget {
  final List<AllChapter> chapters;
  final int initialIndex;

  const PdfChapterPager({
    super.key,
    required this.chapters,
    required this.initialIndex,
  });

  @override
  State<PdfChapterPager> createState() => _PdfChapterPagerState();
}

class _PdfChapterPagerState extends State<PdfChapterPager> {
  late PageController _pageController;

  void _goToNextChapter() {
    if (_pageController.page != null) {
      final current = _pageController.page!.round();
      if (current < widget.chapters.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapters[_pageController.hasClients
              ? _pageController.page?.round() ?? widget.initialIndex
              : widget.initialIndex].chapterName,
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.chapters.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _ChapterPdfView(
            chapter: widget.chapters[index],
            onChapterEnd: _goToNextChapter, // 👈 NEW
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _ChapterPdfView extends StatefulWidget {
  final AllChapter chapter;
  final VoidCallback onChapterEnd;

  const _ChapterPdfView({
    required this.chapter,
    required this.onChapterEnd,
  });

  @override
  State<_ChapterPdfView> createState() => _ChapterPdfViewState();
}

class _ChapterPdfViewState extends State<_ChapterPdfView> {
  late PdfViewerController _controller;

  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {

    return SfPdfViewer.network(
      widget.chapter.attachment,
      controller: _controller,
      scrollDirection: PdfScrollDirection.horizontal,
      pageLayoutMode: PdfPageLayoutMode.single,
      enableTextSelection: true,

      onDocumentLoaded: (details) {
        _totalPages = _controller.pageCount;
      },

      onPageChanged: (details) {
        if (_totalPages != 0 &&
            details.newPageNumber == _totalPages) {
          // 📌 Reached end of this chapter
          widget.onChapterEnd();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
