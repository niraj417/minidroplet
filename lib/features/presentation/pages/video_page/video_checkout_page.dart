import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/utils/get_iap_product_key.dart';
import 'package:tinydroplets/features/presentation/pages/checkout_page/model/all_coupon_code_model.dart';
import 'package:tinydroplets/features/presentation/pages/checkout_page/model/apply_coupon_model.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_list/bloc/ebook_state.dart';
import 'package:tinydroplets/features/presentation/pages/subscription/subscription_screen.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/bloc/video_page_bloc/video_page_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/model/recipe_coupon_model.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/paypal_webview_page.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/recipe_detail_page.dart';

import '../../../../common/widgets/loader.dart';
import '../../../../core/services/iap_services/iap_services.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/services/payment_service/payment_bloc.dart';
import '../../../../core/services/payment_service/payment_event.dart';
import '../../../../core/services/payment_service/payment_state.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../injections/dependency_injection.dart';
import '../ebook_page/ebook_list/bloc/ebook_bloc.dart';
import '../ebook_page/purchased_ebook/purchased_ebook_detail_page.dart';
import '../remove_ads/widget/remove_ads_bottom_sheet.dart';
import 'model/all_recipe_video_model.dart';

class VideoCheckoutPage extends StatefulWidget {
  final int id;
  final String title;
  final String thumbnail;
  final String amount;
  final String mainPrice;

  const VideoCheckoutPage({
    super.key,
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.amount,
    required this.mainPrice,
  });

  @override
  State<VideoCheckoutPage> createState() => _VideoCheckoutPageState();
}

class _VideoCheckoutPageState extends State<VideoCheckoutPage> {
  final TextEditingController _controller = TextEditingController();
  final PaymentService _paymentService = sl<PaymentService>();
  String? _appliedCoupon;
  String? mainPrice;

  // Payment data
  String? orderId;
  String? amount;
  String? name;
  String? contact;
  String? email;
  bool isSubscribed = false;

  late final PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    _paymentBloc = sl<PaymentBloc>();
    _getAllCoupon();
    amount = widget.amount;
    _getPrefData();
    _createOrder();
  }

  Future<void> _refreshPage() async {
    await SubscriptionPaymentService.hasActiveSubscription().then((status) {
      setState(() {
        isSubscribed = status;
      });
    });
  }

  void _getPrefData() {
    final prefData = SharedPref.getLoginData();
    name = prefData?.data?.name ?? '';
    contact = prefData?.data?.mobile ?? '';
    email = prefData?.data?.email ?? '';
    isSubscribed = SharedPref.getBool("isSubscribed") ?? false;
  }

  bool _isPaymentLoading = false;

  Future<void> _createOrder() async {
    setState(() {
      _isPaymentLoading = true;
    });
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.recipeCreateOrder,
        {"video_id": widget.id},
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
      }
    } catch (e) {
      setState(() {
        _isPaymentLoading = false;
      });
    }
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
      }
    } catch (e) {
      setState(() {
        _allCouponLoading = false;
      });
    }
  }

  bool _applyCoupon = false;
  bool _isExpired = false;

  List<RecipeCouponDataModel> _recipeCouponList = [];
  Future<void> _applyCouponCode(String addCoupon) async {
    setState(() {
      _applyCoupon = true;
    });
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.recipeApplyCouponCode,
        {"cupon_code": addCoupon, "order_id": orderId},
      );

      if (response.data['status'] == 1) {
        final applyCouponCodeData = RecipeCouponModel.fromJson(response.data);

        setState(() {
          amount = applyCouponCodeData.data!.amount;
          _recipeCouponList = [applyCouponCodeData.data!];
          _applyCoupon = false;
          _isExpired = false;
        });
        CommonMethods.devLog(logName: 'Assigned order id', message: orderId);
      } else {
        setState(() {
          _applyCoupon = false;
        });
        if (mounted) {
          setState(() {
            _isExpired = true;
          });
          CommonMethods.showSnackBar(context, 'Coupon code expired !');
          return;
        }
      }
    } catch (e) {
      setState(() {
        _applyCoupon = false;
        _appliedCoupon = null;
      });

      if (mounted) {
        setState(() {
          _isExpired = true;
          _appliedCoupon = null;
        });
        CommonMethods.showSnackBar(context, 'Coupon code expired !');
        return;
      }
    }
  }

  bool _removeCoupon = false;

  Future<void> _removeCouponCode() async {
    setState(() {
      _removeCoupon = true;
    });
    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.recipeRemoveCouponCode,
        {"order_id": orderId},
      );

      if (response.data['status'] == 1) {
        final removeCouponCode = RecipeCouponModel.fromJson(response.data);

        setState(() {
          _recipeCouponList = [removeCouponCode.data!];
          amount = removeCouponCode.data!.amount;
          _removeCoupon = false;
        });
        CommonMethods.devLog(logName: 'Assigned order id', message: orderId);
      } else {
        setState(() {
          _removeCoupon = false;
        });
      }
    } catch (e) {
      setState(() {
        _removeCoupon = false;
      });
    }
  }

  Future<void> _fetchPaypal() async {
    try {
      final response = await dioClient.sendPostRequest(ApiEndpoints.paypal, {
        "id": widget.id,
        "type": 'video',
        "amount": amount,
      });

      if (response.data['status'] == 1) {
        final data = response.data['data'];
      } else {
        debugPrint('Something went wrong');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideoPageCubit>(
      create: (context) => VideoPageCubit(),
      child: BlocListener<PaymentBloc, PaymentState>(
        bloc: _paymentBloc,
        listener: (context, state) {
          if (state is PaymentSuccess) {
            CommonMethods.showSnackBar(context, 'Payment success');
            context.read<VideoPageCubit>().refreshData();

            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                builder:
                    (context) =>
                        RecipeDetailScreen(videoId: state.dataId.toString()),
              ),
              (route) => route.isFirst,
            );
          } else if (state is PaymentError) {
            CommonMethods.showSnackBar(context, state.message);
          }
          // IAP State Listeners
          else if (state is IAPSuccess) {
            CommonMethods.showSnackBar(context, 'Purchase successful!');
            context.read<VideoPageCubit>().refreshData();

            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                builder:
                    (context) =>
                        RecipeDetailScreen(videoId: state.dataId.toString()),
              ),
              (route) => route.isFirst,
            );
          } else if (state is IAPError) {
            CommonMethods.showSnackBar(
              context,
              'Purchase failed: ${state.message}',
            );
          } else if (state is IAPPending) {
            CommonMethods.showSnackBar(context, state.message);
          } else if (state is IAPRestored) {
            if (state.restoredProducts.isNotEmpty) {
              CommonMethods.showSnackBar(
                context,
                'Restored ${state.restoredProducts.length} purchase(s)',
              );
            } else {
              CommonMethods.showSnackBar(context, 'No purchases to restore');
            }
          }
        },
        child: SafeArea(
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
              actions: [
                // Add restore purchases button for iOS
                if (Platform.isIOS)
                  TextButton(
                    onPressed: () {
                      _paymentBloc.add(RestoreIAPurchases());
                    },
                    child: Text('Restore'),
                  ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tiny Droplets Shop",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: CustomImage(
                            imageUrl: widget.thumbnail,
                            height: 160,
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Title: ${widget.title}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            // Text(
                            //   "Amount: ${CommonMethods.formatRupees(amount ?? '')}",
                            // ),
                            // SizedBox(height: 4),
                            // Row(
                            //   children: [
                            //     Text(
                            //       CommonMethods.formatRupees(widget.mainPrice),
                            //       style: TextStyle(
                            //         decoration: TextDecoration.lineThrough,
                            //         color: Colors.grey,
                            //       ),
                            //     ),
                            //     SizedBox(width: 8),
                            //     Text(
                            //       CommonMethods.formatRupees(amount ?? ''),
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 18,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 32, thickness: 1),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_appliedCoupon == null || _isExpired)
                          TextField(
                            maxLines: 1,
                            maxLength: 10,
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: 'Enter coupon code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              suffixIcon: TextButton(
                                onPressed: () {
                                  if (_controller.text.isNotEmpty) {
                                    setState(() {
                                      _appliedCoupon = _controller.text;
                                    });
                                  }
                                },
                                child: Text('Apply'),
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Coupon: $_appliedCoupon',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green[800],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _appliedCoupon = null;
                                      _controller.clear();
                                    });
                                    _removeCouponCode();
                                  },
                                  icon: Icon(Icons.close, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    // Divider(height: 32, thickness: 1),
                    // _allCouponLoading
                    //     ? Loader()
                    //     : Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text('Apply Coupon', style: TextStyle(fontSize: 19)),
                    //         SizedBox(height: 10),
                    //         SizedBox(
                    //           height: 40,
                    //           width: double.infinity,
                    //           child: ListView.builder(
                    //             itemCount: _allCouponList.length,
                    //             scrollDirection: Axis.horizontal,
                    //             itemBuilder: (context, index) {
                    //               return Padding(
                    //                 padding: const EdgeInsets.only(right: 8.0),
                    //                 child: InkWell(
                    //                   onTap: () async {
                    //                     if (_allCouponList[index].name.isNotEmpty) {
                    //                       _appliedCoupon =
                    //                           _allCouponList[index].name;
                    //                       await _applyCouponCode(
                    //                         _appliedCoupon ?? '',
                    //                       );
                    //                     }
                    //                   },
                    //                   child: Container(
                    //                     padding: EdgeInsets.symmetric(
                    //                       horizontal: 10,
                    //                       vertical: 3,
                    //                     ),
                    //                     alignment: Alignment.center,
                    //                     decoration: BoxDecoration(
                    //                       borderRadius: BorderRadius.circular(8),
                    //                       color: Theme.of(context).cardColor,
                    //                     ),
                    //                     child: Text(
                    //                       _allCouponList[index].name,
                    //                       style: TextStyle(
                    //                         fontSize: 14,
                    //                         fontStyle: FontStyle.italic,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //         Divider(height: 32, thickness: 1),
                    //       ],
                    //     ),

                    // _recipeCouponList.isNotEmpty
                    //     ? Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           "Order Summary",
                    //           style: TextStyle(fontWeight: FontWeight.bold),
                    //         ),
                    //         SizedBox(height: 8),
                    //         ListView.builder(
                    //           itemCount: _recipeCouponList.length,
                    //           shrinkWrap: true,
                    //           physics: NeverScrollableScrollPhysics(),
                    //           itemBuilder: (context, index) {
                    //             final data = _recipeCouponList[index];
                    //             return Padding(
                    //               padding: const EdgeInsets.symmetric(
                    //                 vertical: 4.0,
                    //               ),
                    //               child: Column(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   _buildSummaryRow(
                    //                     'Amount:',
                    //                     '₹${CommonMethods.formatRupees(amount ?? '')}',
                    //                   ),
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
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
        //       "Overall Total",
        //       style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        //     ),
        //     Text(
        //       CommonMethods.formatRupees(amount ?? ''),
        //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        //     ),
        //   ],
        // ),
        AppButton(
          useCupertino: true,
          width: 200,
          //text: 'Pay Now',
          text: 'Subscribe to Unlock',
          onPressed: () async {

            goto(context, SubscriptionPage());

            // await showModalBottomSheet(
            //   context: context,
            //   isScrollControlled: true,
            //   backgroundColor: Colors.transparent,
            //   builder: (context) => const RemoveAdsBottomSheet(),
            // );

            // if (Platform.isIOS) {
            //   final productId = IAPUtils.getIAPProductId('video');
            //   if (productId != null) {
            //     CommonMethods.devLog(
            //       logName: 'Video Order id here',
            //       message: orderId,
            //     );
            //     try {
            //       _paymentBloc.add(
            //         InitiateIAPurchase(
            //           productId: IAPService.videoProductId,
            //           dataId: widget.id,
            //           itemType: 'video',
            //           orderId: orderId!,
            //         ),
            //       );
            //
            //       CommonMethods.showSnackBar(
            //         context,
            //         'Processing In-App Purchase...',
            //       );
            //     } catch (e) {
            //       CommonMethods.devLog(
            //         logName: 'IAP Error',
            //         message: e.toString(),
            //       );
            //       CommonMethods.showSnackBar(
            //         context,
            //         "Something went wrong. Please try again.",
            //       );
            //     }
            //   } else {
            //     CommonMethods.showSnackBar(context, "Order ID is missing.");
            //   }
            // } else {
            //   await _buildPaymentMode(context);
            // }
          },
        ),
        SizedBox(height: 120,),
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
                //'Choose Payment Mode',
                'Subscription',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  // Expanded(
                  //   child: AppButton(
                  //     onPressed: () {
                  //       // if (amount!.isNotEmpty && orderId!.isNotEmpty) {
                  //       //   CommonMethods.devLog(
                  //       //     logName: 'Video Order id here',
                  //       //     message: orderId,
                  //       //   );
                  //       //   try {
                  //       //     _paymentBloc.add(
                  //       //       InitiatePayment(
                  //       //         amount: amount ?? '0',
                  //       //         orderId: orderId ?? '',
                  //       //         dataId: widget.id,
                  //       //         name: name ?? '',
                  //       //         contact: contact ?? '',
                  //       //         email: email ?? '',
                  //       //         itemType: 'video',
                  //       //       ),
                  //       //     );
                  //       //   } catch (e) {
                  //       //     CommonMethods.devLog(
                  //       //       logName: 'Error',
                  //       //       message: e.toString(),
                  //       //     );
                  //       //   }
                  //       // } else {
                  //       //   CommonMethods.showSnackBar(
                  //       //     context,
                  //       //     "Something went wrong, Please try again later",
                  //       //   );
                  //       // }
                  //       Navigator.pop(context);
                  //       CommonMethods.showSnackBar(
                  //         context,
                  //         'Payment Mode: Razorpay',
                  //       );
                  //     },
                  //     text: 'Razorpay',
                  //   ),
                  // ),
                  SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      onPressed: () {
                        gotoReplacement(context, SubscriptionPage());
                        // showModalBottomSheet(
                        //   context: context,
                        //   isScrollControlled: true,
                        //   backgroundColor: Colors.transparent,
                        //   builder: (context) => const RemoveAdsBottomSheet(),
                        // );
                        //_openRemoveAdsSubscription();
                        // Navigator.pop(context);
                        // goto(
                        //   context,
                        //   PaypalWebViewPage(
                        //     id: widget.id,
                        //     type: 'video',
                        //     amount: amount ?? '0',
                        //   ),
                        // );
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
  // void _openRemoveAdsSubscription() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => const RemoveAdsBottomSheet(),
  //   );
  // }
}
