import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tinydroplets/common/widgets/app_bar/normal_app_bar.dart';
import 'package:tinydroplets/core/services/sharing_handler.dart';
import 'package:tinydroplets/features/components/report_content/report_content.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/all_review_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/purchased_ebook_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/purchased_ebook/widget/rating_bottom_sheet.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_player/audio_player.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/book_palette_card.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/ebook_read_mode.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/expandable_text.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/saved_bloc/saved_cubit.dart';
import '../../../../../core/constant/app_export.dart';

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:get_it/get_it.dart';
import 'package:tinydroplets/common/widgets/app_bar/normal_app_bar.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/ebook_detail_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/purchased_ebook/purchased_ebook_detail_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/book_palette_card.dart';
import 'package:tinydroplets/features/presentation/pages/pdf_viewer/pdf_viewer_screen.dart';
import '../../../../../core/constant/app_export.dart';
import '../../../../../core/services/payment_service.dart';
import '../../../../../injections/dependency_injection.dart';
import '../../feed_page/bloc/feed_bloc.dart';

class PurchasedEbookBuyDetailPage extends StatefulWidget {
  final int ebookId;
  const PurchasedEbookBuyDetailPage({super.key, required this.ebookId});

  @override
  State<PurchasedEbookBuyDetailPage> createState() =>
      _PurchasedEbookBuyDetailPageState();
}

class _PurchasedEbookBuyDetailPageState
    extends State<PurchasedEbookBuyDetailPage> {
  double ratingText = 0.0;
  final DioClient dioClient = GetIt.instance<DioClient>();
  int? _selectedIndex;
  List<PurchasedEbookDataModel> _purchasedEbook = [];
  bool _isAllEbookLoading = true;
  final PaymentService _paymentService = sl<PaymentService>();

  String? bookName;
  String? description;
  String? image;
  String? author;
  String? page;
  String? price;
  String? audio;
  dynamic totalReview;
  String? preview;
  String? _isSaved;

  String? orderId;
  String? amount;
  String? name;
  String? contact;
  String? email;

  Future<void> _onEbookDetailData() async {
    CommonMethods.devLog(logName: 'Ebook id', message: widget.ebookId);
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.purchasedEbook,
        {"ebook_id": widget.ebookId},
      );

      if (response.data['status'] == 1) {
        final data = PurchasedEbookModel.fromJson(response.data);

        CommonMethods.devLog(logName: 'Ebook detail', message: data.data);

        setState(() {
          if (data.data != null) {
            bookName = data.data!.title;
            description = data.data!.description;
            image = data.data!.coverImage;
            author = data.data!.authorName;
            page = data.data!.pages;

            price = data.data!.price;
            audio = data.data!.audio;
            totalReview = data.data!.totalReview;
            preview = data.data!.preview;
            _isSaved = data.data!.isSaved;

            _purchasedEbook = [data.data!];
          }

          debugPrint(totalReview.toString());
          _isAllEbookLoading = false;
        });
      } else {
        setState(() {
          _isAllEbookLoading = false;
        });
        debugPrint('Failed to load data: ${response.data['message']}');
      }
    } catch (e, stackTrace) {
      setState(() {
        _isAllEbookLoading = false;
      });
      debugPrint('Catch me Error fetching ebook detail data: $e');
      debugPrint('Stack Trace: $stackTrace');
    }
  }

  List<AllReviewDataModel> _allReviewDataModel = [];

  Future<void> _fetchAllReview() async {
    CommonMethods.devLog(
      logName: 'Ebook id for review',
      message: widget.ebookId,
    );
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.ebookAllReview,
        {
          // "ebook_id": 4,
          "ebook_id": widget.ebookId,
        },
      );
      CommonMethods.devLog(logName: 'Review data', message: response.data);

      if (response.data['status'] == 1) {
        final data = AllReviewModel.fromJson(response.data);
        setState(() {
          _allReviewDataModel = data.data;
        });

        CommonMethods.devLog(logName: 'Review comments', message: data.data);
      } else {
        debugPrint('Failed to load data: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error fetching ebook review: $e');
    }
  }

  Future<void> _saveEbook() async {
    try {
      final response = await dioClient.sendPostRequest(ApiEndpoints.saveEbook, {
        "ebook_id": widget.ebookId,
      });
      CommonMethods.devLog(logName: 'Save ebook  data', message: response.data);

      if (response.data['status'] == 1) {
        setState(() {
          _isSaved = '1';
        });
        if (mounted) {
          CommonMethods.showSnackBar(context, 'Saved ebook');
        }
      } else {
        if (mounted) {
          CommonMethods.showSnackBar(context, 'Failed to save ebook');
        }
        debugPrint('Failed to load data: ${response.data['message']}');
      }
    } catch (e) {
      if (mounted) {
        CommonMethods.showSnackBar(context, e.toString());
      }
      debugPrint('Error fetching ebook review: $e');
    }
  }

  // Future<void> _addEbookRating() async {
  //   try {
  //     final response =
  //         await dioClient.sendPostRequest(ApiEndpoints.addEbookRating, {
  //       "ebook_id": widget.ebookId,
  //       "rating": 3,
  //       "review": 'Add comments here',
  //     });
  //
  //     if (response.data['status'] == 1) {
  //       // final data = PurchasedEbookModel.fromJson(response.data);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isAllEbookLoading = false;
  //     });
  //     debugPrint('Ebook rating data: $e');
  //   }
  // }

  void _getPrefData() {
    final prefData = SharedPref.getLoginData();
    name = prefData?.data?.name ?? '';
    contact = prefData?.data?.mobile ?? '';
    email = prefData?.data?.email ?? '';
  }

  @override
  void initState() {
    super.initState();
    _onEbookDetailData();
    _getPrefData();
    if (widget.ebookId != -1) {
      _fetchAllReview();
    }
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.share_up),
            onPressed:
                () => SharingHandler.handleEbookShare(
                  bookName ?? '',
                  author ?? '',
                  description ?? '',
                  context,
                ),
          ),
          IconButton(
            icon: Icon(
              _isSaved == '1'
                  ? CupertinoIcons.bookmark_solid
                  : CupertinoIcons.bookmark,
            ),
            onPressed: () async {
              if (_isSaved == '0') {
                await _saveEbook();
              } else {
                // context.read<SavedItemsCubit>().removeItem(item)
                if (mounted) {
                  CommonMethods.showSnackBar(context, 'Already saved');
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: Color(AppColor.primaryColor),
        color: Colors.white,

        onRefresh: _onEbookDetailData,
        child: SingleChildScrollView(
          // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
          child: Column(
            children: [
              BookPaletteCard(
                imagePath: image ?? DummyData.avatarUrl,
                showPreview: preview == null,
                onPressed: () {
                  if (preview != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PdfViewerPage(pdfUrl: preview ?? ''),
                      ),
                    );
                  } else {
                    CommonMethods.showSnackBar(context, 'No Preview available');
                  }
                },
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        showRatingSheet(context, widget.ebookId);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color: Color(AppColor.primaryColor),
                          ),
                        ),
                      ),
                    ),
                    ReportContentWidget(
                      contentId: widget.ebookId,
                      contentType: 'e_book',
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      bookName ?? 'No data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Author: $author" ?? '',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 20),
                    _bookReview(),
                    SizedBox(height: 20),
                    ExpandableTextWidget(text: description ?? 'No data'),
                    SizedBox(height: 10),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        itemCount: _purchasedEbook.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final chapters = _purchasedEbook[index].allChapters;
                          final purchasedEbook = _purchasedEbook[index];
                          CommonMethods.devLog(
                            logName: 'Load chapter',
                            message: chapters.runtimeType,
                          );

                          return Column(
                            children: [
                              ListView.builder(
                                itemCount: chapters.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, chapterIndex) {
                                  final chapterData = chapters[chapterIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedIndex =
                                                  (_selectedIndex ==
                                                          chapterIndex)
                                                      ? null
                                                      : chapterIndex;
                                            });
                                          },
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              chapterData.chapterName,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        if (_selectedIndex == chapterIndex)
                                          _buildReader(
                                            context,
                                            chapterData,
                                            purchasedEbook,
                                          ),
                                        Divider(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildReader(
    BuildContext context,
    AllChapter chapterData,
    PurchasedEbookDataModel purchasedEbookDataModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap:
                  () => goto(
                    context,
                    PdfViewerPage(pdfUrl: chapterData.attachment),
                  ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.book, size: 20),
                  SizedBox(width: 5),
                  Text('Read', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(width: 20),
            Visibility(
              visible: Platform.isAndroid,
              child: InkWell(
                onTap:
                    (audio == "Not Avalible")
                        // (purchasedEbookDataModel.audio.isEmpty && purchasedEbookDataModel.audio == null && audio == 'Not Avalible')
                        ? () {
                          CommonMethods.showSnackBar(
                            context,
                            'Audio not available',
                          );
                        }
                        : () {
                          goto(
                            context,
                            AudioPlayerScreen(
                              purchasedEbookDataModel: purchasedEbookDataModel,
                            ),
                          );
                        },
                child: Row(
                  children: [
                    Icon(CupertinoIcons.headphones, size: 20),
                    SizedBox(width: 5),
                    Text('Listen', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _bookReview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              'Audio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(audio ?? 'Not available', style: TextStyle(fontSize: 13)),
          ],
        ),
        SizedBox(
          height: 40,
          child: VerticalDivider(thickness: 2, color: Colors.grey.shade300),
        ),
        Column(
          children: [
            Text(
              page ?? 'No data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Pages', style: TextStyle(fontSize: 13)),
          ],
        ),
        SizedBox(
          height: 40,
          child: VerticalDivider(thickness: 2, color: Colors.grey.shade300),
        ),
        InkWell(
          onTap: () {
            if (_allReviewDataModel.isNotEmpty) {
              _showReviewSheet(context, _allReviewDataModel);
            }
          },
          child: Column(
            children: [
              Text(
                totalReview.toString() ?? '0',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text("Reviews", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  void _showReviewSheet(
    BuildContext context,
    List<AllReviewDataModel> allReviewData,
  ) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ListView.builder(
              //   controller: scrollController,
              itemCount: allReviewData.length,
              itemBuilder: (context, index) {
                final data = allReviewData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 5,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture
                          Container(
                            height: 44,
                            width: 44,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: CustomImage(imageUrl: data.profile),
                          ),
                          SizedBox(width: 10),

                          // User Details and Review
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.username,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    int.parse(data.rating),
                                    (index) {
                                      return Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 16,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  data.review,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showRatingSheet(BuildContext context, int ebookId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => RatingBottomSheet(
            ebookId: ebookId,
            onRatingSubmitted: (success) {
              if (success) {
                _fetchAllReview();
                setState(() {});
              }
            },
          ),
    );
  }
}
