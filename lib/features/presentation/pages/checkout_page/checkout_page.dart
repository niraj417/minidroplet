import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/utils/get_iap_product_key.dart';
import 'package:tinydroplets/features/presentation/pages/checkout_page/model/all_coupon_code_model.dart';
import 'package:tinydroplets/features/presentation/pages/checkout_page/model/apply_coupon_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_list/bloc/ebook_state.dart';
import 'package:tinydroplets/services/in_app_purchases.dart';

import '../../../../core/services/payment_service.dart';
import '../../../../core/services/payment_service/payment_bloc.dart';
import '../../../../core/services/payment_service/payment_event.dart';
import '../../../../core/services/payment_service/payment_state.dart';
import '../../../../injections/dependency_injection.dart';
import '../ebook_page/ebook_list/bloc/ebook_bloc.dart';
import '../ebook_page/purchased_ebook/purchased_ebook_detail_page.dart';
import '../video_page/paypal_webview_page.dart';

class CheckoutPage extends StatefulWidget {
  final String orderId;
  final int ebookId;
  final String ebookCover;
  final String ebookName;
  final String authorName;
  final String totalPage;
  final String audio;
  final String amount;
  final String discountPercentage;
  final String mainPrice;
  final String name;
  final String contact;
  final String email;

  const CheckoutPage({
    super.key,
    required this.orderId,
    required this.ebookId,
    required this.ebookCover,
    required this.ebookName,
    required this.authorName,
    required this.totalPage,
    required this.audio,
    required this.amount,
    required this.discountPercentage,
    required this.mainPrice,
    required this.name,
    required this.contact,
    required this.email,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final IAPurchaseService purchaseService = IAPurchaseService();
  final TextEditingController _controller = TextEditingController();
  final PaymentService _paymentService = sl<PaymentService>();
  String? _appliedCoupon;
  String? orderId;
  String? amount;
  String? mainPrice;

  late final PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    _paymentBloc = sl<PaymentBloc>();
    _getAllCoupon();
    amount = widget.amount;
    orderId = widget.orderId;
    _setupPurchases();
  }

  bool _allCouponLoading = false;
  List<AllCouponCodeDataModel> _allCouponList = [];

  Future<void> _getAllCoupon() async {
    setState(() {
      _allCouponLoading = true;
    });

    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.allCoupon);

      if (response.data['status'] == 1) {
        final allCouponModel = AllCouponCodeModel.fromJson(response.data);

        setState(() {
          _allCouponList = allCouponModel.data;
          _allCouponLoading = false;
        });
      } else {
        setState(() {
          _allCouponLoading = false;
        });
        print('Failed to load data: ${response.data['message']}');
      }
    } catch (e) {
      setState(() {
        _allCouponLoading = false;
      });
      print('Error fetching coupon data: $e');
    }
  }

  bool _applyCoupon = false;

  List<ApplyCouponDataModel> _applyCouponList = [];
  Future<void> _applyCouponCode(String addCoupon) async {
    setState(() {
      _applyCoupon = true;
    });
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.applyCoupon,
        {"cupon_code": addCoupon, "order_id": orderId},
      );

      if (response.data['status'] == 1) {
        final applyCouponCodeData = ApplyCouponModel.fromJson(response.data);

        setState(() {
          amount = applyCouponCodeData.data!.amount;

          _applyCouponList = [applyCouponCodeData.data!];

          _applyCoupon = false;
        });
        CommonMethods.devLog(logName: 'Assigned order id', message: orderId);
      } else {
        setState(() {
          _applyCoupon = false;
        });
        print('Failed to load data: ${response.data['message']}');
        if (mounted) {
          CommonMethods.showSnackBar(context, 'Coupon code expired !');
          return;
        }
      }
    } catch (e) {
      setState(() {
        _applyCoupon = false;
      });
      print('Error fetching create order detail data: $e');
      if (mounted) {
        CommonMethods.showSnackBar(context, 'Coupon code expired !');
        return;
      }
    }
  }

  bool _removeCoupon = false;

  // List<ApplyCouponDataModel> _removeCouponCodeData = [];
  Future<void> _removeCouponCode() async {
    setState(() {
      _removeCoupon = true;
    });
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.removeCoupon,
        {"order_id": orderId},
      );

      if (response.data['status'] == 1) {
        final removeCouponCode = ApplyCouponModel.fromJson(response.data);

        setState(() {
          _applyCouponList = [removeCouponCode.data!];
          amount = removeCouponCode.data!.amount;
          _removeCoupon = false;
        });
        CommonMethods.devLog(logName: 'Assigned order id', message: orderId);
      } else {
        setState(() {
          _removeCoupon = false;
        });
        print('Failed to load data: ${response.data['message']}');
      }
    } catch (e) {
      setState(() {
        _removeCoupon = false;
      });
      print('Error fetching create order detail data: $e');
    }
  }

  Future<void> _setupPurchases() async {
    await purchaseService.initialize();
    // await purchaseService.lo
  }

  @override
  void dispose() {
    purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      bloc: _paymentBloc,
      listener: (context, state) {
        if (state is PaymentSuccess) {
          CommonMethods.showSnackBar(
            context,
            'Payment success',
          ); // ✅ Dismiss Razorpay overlay
          Navigator.of(context, rootNavigator: true).maybePop();
          final ebookBloc = context.read<EbookBloc>();
          ebookBloc.add(FetchAllEbookData());

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      PurchasedEbookBuyDetailPage(ebookId: state.dataId),
            ),
            (route) => route.isFirst,
          );
        } else if (state is PaymentError) {
          CommonMethods.showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        bottomSheet: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          color: Theme.of(context).scaffoldBackgroundColor,
          height: 80,
          child: buildPaymentButton(),
        ),
        appBar: AppBar(
          title: Text(
            "Checkout Page",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tiny Droplets Shop",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImage(
                    // imageUrl: DummyData.avatarUrl,
                    imageUrl: widget.ebookCover,
                    width: 80,
                    height: 140,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ebook: ${widget.ebookName}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("Author: ${widget.authorName}"),
                        SizedBox(height: 4),
                        Text(
                          "Amount: ${CommonMethods.formatRupees(widget.amount)}",
                        ),
                        // Text("Amount: ₹${widget.amount}"),
                        // SizedBox(height: 4),
                        // Row(
                        //   children: [
                        //     Text("Total discount: "),
                        //     Text(
                        //       "${widget.discountPercentage}%",
                        //       style: TextStyle(
                        //           color: Colors.red, fontWeight: FontWeight.bold),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              CommonMethods.formatRupees(widget.mainPrice),
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              CommonMethods.formatRupees(widget.amount ?? ''),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Divider(height: 32, thickness: 1),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     if (_appliedCoupon == null)
              //       TextField(
              //         maxLines: 1,
              //         maxLength: 10,
              //         controller: _controller,
              //         decoration: InputDecoration(
              //           labelText: 'Enter coupon code',
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(8),
              //           ),
              //           contentPadding: EdgeInsets.symmetric(
              //             vertical: 8,
              //             horizontal: 12,
              //           ),
              //           suffixIcon: TextButton(
              //             onPressed: () {
              //               if (_controller.text.isNotEmpty) {
              //                 setState(() {
              //                   _appliedCoupon = _controller.text;
              //                 });
              //               }
              //             },
              //             child: Text('Apply'),
              //           ),
              //         ),
              //       )
              //     else
              //       Container(
              //         padding: EdgeInsets.symmetric(
              //           vertical: 12,
              //           horizontal: 16,
              //         ),
              //         decoration: BoxDecoration(
              //           color: Colors.green.withValues(alpha: 0.1),
              //           borderRadius: BorderRadius.circular(8),
              //           border: Border.all(color: Colors.green.shade300),
              //         ),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Text(
              //               'Coupon: $_appliedCoupon',
              //               style: TextStyle(
              //                 fontSize: 16,
              //                 color: Colors.green[800],
              //                 fontStyle: FontStyle.italic,
              //               ),
              //             ),
              //             IconButton(
              //               onPressed: () {
              //                 setState(() {
              //                   _appliedCoupon = null;
              //                   _controller.clear();
              //                 });
              //                 _removeCouponCode();
              //               },
              //               icon: Icon(Icons.close, color: Colors.red),
              //             ),
              //           ],
              //         ),
              //       ),
              //   ],
              // ),
              //Divider(height: 32, thickness: 1),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text('Apply Coupon', style: TextStyle(fontSize: 19)),
              //     SizedBox(height: 10),
              //     SizedBox(
              //       height: 40,
              //       width: double.infinity,
              //       child: ListView.builder(
              //         itemCount: _allCouponList.length,
              //         scrollDirection: Axis.horizontal,
              //         itemBuilder: (context, index) {
              //           return Padding(
              //             padding: const EdgeInsets.only(right: 8.0),
              //             child: InkWell(
              //               onTap: () {
              //                 if (_allCouponList[index].name.isNotEmpty) {
              //                   _appliedCoupon = _allCouponList[index].name;
              //                   _applyCouponCode(_appliedCoupon ?? '');
              //                 }
              //               },
              //               child: Container(
              //                 padding: EdgeInsets.symmetric(
              //                   horizontal: 10,
              //                   vertical: 3,
              //                 ),
              //                 alignment: Alignment.center,
              //                 decoration: BoxDecoration(
              //                   borderRadius: BorderRadius.circular(8),
              //                   color: Theme.of(context).cardColor,
              //                 ),
              //                 child: Text(
              //                   _allCouponList[index].name,
              //                   style: TextStyle(
              //                     fontSize: 14,
              //                     fontStyle: FontStyle.italic,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              // Divider(height: 32, thickness: 1),
              // _applyCouponList.isNotEmpty
              //     ? Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           "Order Summary",
              //           style: TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //         SizedBox(height: 8),
              //         ListView.builder(
              //           itemCount: _applyCouponList.length,
              //           shrinkWrap: true,
              //           physics: NeverScrollableScrollPhysics(),
              //           itemBuilder: (context, index) {
              //             final data = _applyCouponList[index];
              //             return Padding(
              //               padding: const EdgeInsets.symmetric(vertical: 4.0),
              //               child: Column(
              //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   _buildSummaryRow(
              //                     'Amount:',
              //                     '₹${CommonMethods.formatRupees(amount ?? '')}',
              //                   ),
              //                   // _buildSummaryRow('Amount:', '₹${data.amount}'),
              //                   _buildSummaryRow(
              //                     'Total discount:',
              //                     "₹${data.discountAmount}",
              //                   ),
              //                   _buildSummaryRow(
              //                     'Discount percentage:',
              //                     "${data.discountPercentage}%",
              //                   ),
              //                 ],
              //               ),
              //             );
              //           },
              //         ),
              //       ],
              //     )
              //     : Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           "Order Summary",
              //           style: TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //         SizedBox(height: 8),
              //         Column(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             _buildSummaryRow(
              //               'Amount:',
              //               CommonMethods.formatRupees(amount ?? ''),
              //             ),
              //             // _buildSummaryRow('Total discount:', "₹${data.discountAmount}"),
              //             // _buildSummaryRow('Discount percentage:', "${data.discountPercentage}%"),
              //           ],
              //         ),
              //       ],
              //     ),
              // Divider(height: 32, thickness: 1),
            ],
          ),
        ),
      ),
    );
  }

  Row buildPaymentButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overall Total",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            ),
            Text(
              CommonMethods.formatRupees(amount ?? ''),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        // _isPaymentLoading
        //     ? Loader()
        //     :
        AppButton(
          useCupertino: true,
          width: 180,
          text: 'Pay Now',
          onPressed: () async {
            if (Platform.isAndroid) {
              await _buildPaymentMode(context);
              return;
            }

            if (Platform.isIOS) {
              final productId = IAPUtils.getIAPProductId(
                'ebook',
              ); // helper method defined below
              if (productId != null) {
                try {
                  _paymentBloc.add(
                    InitiatePurchase(
                      orderId: widget.orderId,
                      amount: widget.amount,
                      dataId: widget.ebookId,
                      name: widget.name,
                      contact: widget.contact,
                      email: widget.email,
                      itemType: 'ebook',
                    ),
                  );
                } catch (e) {
                  CommonMethods.devLog(
                    logName: 'IAP Error',
                    message: e.toString(),
                  );
                }
              } else {
                CommonMethods.showSnackBar(context, 'Invalid product ID');
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), Text(value)],
      ),
    );
  }

  Future<void> _buildPaymentMode(BuildContext context) async {
    await showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 26.0, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Payment Mode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  // Expanded(
                  //   child: AppButton(
                  //     onPressed: () {
                  //       if (amount!.isNotEmpty && orderId!.isNotEmpty) {
                  //         CommonMethods.devLog(
                  //           logName: 'Video Order id here',
                  //           message: orderId,
                  //         );
                  //         try {
                  //           _paymentBloc.add(
                  //             InitiatePurchase(
                  //               amount: widget.amount ?? '0',
                  //               orderId: widget.orderId ?? '',
                  //               dataId: widget.ebookId,
                  //               name: widget.name ?? '',
                  //               contact: widget.contact ?? '',
                  //               email: widget.email ?? '',
                  //               itemType: 'ebook',
                  //             ),
                  //           );
                  //         } catch (e) {
                  //           CommonMethods.devLog(
                  //             logName: 'Error',
                  //             message: e.toString(),
                  //           );
                  //         }
                  //       } else {
                  //         CommonMethods.showSnackBar(
                  //           context,
                  //           "Something went wrong, Please try again later",
                  //         );
                  //       }
                  //       Navigator.pop(context);
                  //       CommonMethods.showSnackBar(
                  //         context,
                  //         'Payment Mode: Razorpay',
                  //       );
                  //     },
                  //     text: 'Razorpay',
                  //   ),
                  // ),
                  //SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      onPressed: () {
                        Navigator.pop(context);
                        goto(
                          context,
                          PaypalWebViewPage(
                            id: widget.ebookId,
                            type: 'playlist',
                            amount: amount ?? '0',
                          ),
                        );
                        // CommonMethods.showSnackBar(context, 'Payment Mode: PayPal');
                      },
                      text: 'PayPal',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  //
}
