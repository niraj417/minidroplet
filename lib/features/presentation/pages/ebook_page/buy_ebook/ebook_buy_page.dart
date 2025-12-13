import 'package:flutter/cupertino.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:get_it/get_it.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/features/presentation/pages/checkout_page/checkout_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/model/ebook_detail_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/widget/book_palette_card.dart';
import 'package:tinydroplets/features/presentation/pages/pdf_viewer/pdf_viewer_screen.dart';

import '../../../../../core/constant/app_export.dart';
import '../../feed_page/widget/expandable_text.dart';
import '../../remove_ads/widget/remove_ads_bottom_sheet.dart';
import '../model/all_review_model.dart';

class EbookBuyDetailPage extends StatefulWidget {
  final int ebookId;
  const EbookBuyDetailPage({super.key, required this.ebookId});

  @override
  State<EbookBuyDetailPage> createState() => _EbookBuyDetailPageState();
}

class _EbookBuyDetailPageState extends State<EbookBuyDetailPage> {
  double ratingText = 0.0;
  final DioClient dioClient = GetIt.instance<DioClient>();

  List<EbookDetailDataModel> _allEbookItems = [];
  bool _isAllEbookLoading = true;

  // Detail data

  String? ebookName;
  String? description;
  String? image;
  String? authorName;
  String? page;
  String? price;
  String? mainPrice;
  String? audio;
  int? totalReview;
  String? preview;
  // create payment data
  String? orderId;
  String? amount;
  String? name;
  String? contact;
  String? email;

  Future<void> _onEbookDetailData() async {
    CommonMethods.devLog(logName: 'Ebook id', message: widget.ebookId);
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.ebookDetail,
        {"ebook_id": widget.ebookId},
      );

      if (response.data['status'] == 1) {
        final data = EbookDetailModel.fromJson(response.data);

        CommonMethods.devLog(logName: 'Ebook detail', message: data.data);

        setState(() {
          if (data.data != null) {
            ebookName = data.data!.title;
            description = data.data!.description;
            image = data.data!.coverImage;
            authorName = data.data!.authorName;
            page = data.data!.pages;
            price = data.data!.price;
            mainPrice = data.data!.mainPrice;
            audio = data.data!.audio;
            totalReview = data.data!.totalReview;
            preview = data.data!.preview;

            _allEbookItems = [data.data!];
          }
          _isAllEbookLoading = false;
        });
      } else {
        setState(() {
          _isAllEbookLoading = false;
        });
        debugPrint('Failed to load data: ${response.data['message']}');
      }
    } catch (e) {
      setState(() {
        _isAllEbookLoading = false;
      });
      debugPrint('Ebook detail data: $e');
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

  bool isSubscribed = false;

  void _getPrefData() {
    final prefData = SharedPref.getLoginData();
    name = prefData?.data?.name ?? '';
    contact = prefData?.data?.mobile ?? '';
    email = prefData?.data?.email ?? '';
    //isSubscribed = SharedPref.getBool("isSubscribed") ?? false;
    isSubscribed = SharedPref.getBool(SharedPrefKeys.hasPremiumAccess) ?? false;
  }

  @override
  void initState() {
    super.initState();
    _onEbookDetailData();
    _createOrder();
    _getPrefData();
    if (widget.ebookId != -1) {
      _fetchAllReview();
    }
  }

  bool _isPaymentLoading = false;

  Future<void> _createOrder() async {
    setState(() {
      _isPaymentLoading = true;
    });
    CommonMethods.devLog(logName: 'Ebook id', message: widget.ebookId);
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.createOrder,
        {"ebook_id": widget.ebookId},
      );

      if (response.data['status'] == 1) {
        final data = response.data['data'];

        CommonMethods.devLog(
          logName: 'Create payment order id',
          message: data['order_id'],
        );

        setState(() {
          if (data != null) {
            orderId = data['order_id'];

            amount = data['amount'];
          }

          _isPaymentLoading = false;
        });
        CommonMethods.devLog(logName: 'Assigned order id', message: orderId);
      } else {
        setState(() {
          _isPaymentLoading = false;
        });
        debugPrint('Failed to load data: ${response.data['message']}');
      }
    } catch (e) {
      setState(() {
        _isPaymentLoading = false;
      });
      debugPrint('Error fetching create order detail data: $e');
    }
  }

  bool _isShare = false;
  bool _isSave = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        bottomSheet: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).scaffoldBackgroundColor,
          height: 80,
          child: buildPaymentButton(),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(
                _isShare ? CupertinoIcons.share_solid : CupertinoIcons.share_up,
              ),
              onPressed: () {
                setState(() {
                  _isShare = !_isShare;
                });
              },
            ),
            IconButton(
              icon: Icon(
                _isSave ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark,
              ),
              onPressed: () {
                setState(() {
                  _isSave = !_isSave;
                });
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
                  showPreview: true,
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
                StarRating(
                  rating: 3.5,
                  allowHalfRating: true,
                  color: Color(AppColor.primaryColor),
                  onRatingChanged:
                      (rating) => setState(() => ratingText = rating),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        ebookName ?? 'No data',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Author: $authorName" ?? '',
                        // authorName ?? 'No data',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      _bookReview(),
                      SizedBox(height: 20),
                      ExpandableTextWidget(text: description ?? 'No data'),
                      SizedBox(height: 150),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

  Row buildPaymentButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(
        //       "Price",
        //       style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
        //     ),
        //     Text(
        //       CommonMethods.formatRupees(amount ?? ''),
        //       // "₹$amount",
        //       style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        //     ),
        //   ],
        // ),
        AppButton(
          useCupertino: true,
          width: 200,
          text: 'Subscribe to Unlock',
          onPressed: () {

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const RemoveAdsBottomSheet(),
            );

            // if (amount != null &&
            //     orderId != null &&
            //     name != null &&
            //     contact != null &&
            //     email != null) {
            //   goto(
            //     context,
            //     CheckoutPage(
            //       ebookId: widget.ebookId,
            //       orderId: orderId ?? '',
            //       ebookCover: image ?? '',
            //       ebookName: ebookName ?? '',
            //       authorName: authorName ?? '',
            //       totalPage: page ?? '',
            //       audio: audio ?? '',
            //       amount: price ?? '',
            //       discountPercentage: '10',
            //       mainPrice: mainPrice ?? '0',
            //       name: name ?? '',
            //       contact: contact ?? '',
            //       email: email ?? '',
            //     ),
            //   );
            // } else {
            //   CommonMethods.showSnackBar(
            //     context,
            //     "Something went wrong, Please try again later",
            //   );
            // }
          },
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
}
