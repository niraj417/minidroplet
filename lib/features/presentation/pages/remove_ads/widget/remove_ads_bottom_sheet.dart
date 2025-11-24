import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tinydroplets/common/widgets/app_button.dart';
import 'package:tinydroplets/core/utils/shared_pref.dart';
import 'package:tinydroplets/features/presentation/pages/remove_ads/widget/purchase_details_bottom_sheet.dart';

import '../../../../../core/services/remove_ads_payment.dart';
import '../bloc/remove_ads_cubit.dart';
import '../bloc/remove_ads_state.dart';

class RemoveAdsBottomSheet extends StatefulWidget {
  const RemoveAdsBottomSheet({super.key});

  @override
  State<RemoveAdsBottomSheet> createState() => _RemoveAdsBottomSheetState();
}

class _RemoveAdsBottomSheetState extends State<RemoveAdsBottomSheet> {
  late RemoveAdsPaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    context.read<RemoveAdsCubit>().getRemoveAdsPrice();
    _paymentService = RemoveAdsPaymentService();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: BlocConsumer<RemoveAdsCubit, RemoveAdsState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
                  context.read<RemoveAdsCubit>().resetError();
                }
          
                if (state.isPurchased) {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const PurchaseDetailsBottomSheet(),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
          
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        /// Drag Indicator
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
          
                        const SizedBox(height: 20),
          
                        /// HEADER
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2C68EE), Color(0xFF5A8CFF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.lock_open_rounded, size: 42, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                "Unlock Premium Content",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Subscribe to access exclusive paid materials",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
          
                        const SizedBox(height: 20),
          
                        // /// DESCRIPTION
                        // if (state.description != null)
                        //   Text(
                        //     state.description!,
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //       color: Colors.grey.shade700,
                        //       fontSize: 15,
                        //       height: 1.4,
                        //     ),
                        //   ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _FeaturePoint(text: "Access premium baby care content"),
                            _FeaturePoint(text: "Exclusive learning videos"),
                            _FeaturePoint(text: "Expert-curated parenting guides"),
                            _FeaturePoint(text: "Ad-free premium environment"),
                          ],
                        ),
          
          
                        const SizedBox(height: 20),
          
                        /// PRICE CARD
                        if (state.amount != null)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F6FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2C68EE),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "One Time Payment",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "₹${state.amount}",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Color(0xFF2C68EE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
          
                        const SizedBox(height: 30),
          
                        /// CTA BUTTON
                        AppButton(
                          text: 'Subscribe To Unlock',
                          onPressed: () async {
                            if (state.amount != null && state.orderId != null) {
                              final prefData = SharedPref.getLoginData();
                              final name = prefData?.data?.name ?? '';
                              final contact = prefData?.data?.mobile ?? '';
                              final email = prefData?.data?.email ?? '';
          
                              if (Theme.of(context).platform ==
                                  TargetPlatform.iOS) {
                                try {
                                  await _paymentService.makePayment(
                                    context: context,
                                    amount: state.amount!,
                                    orderId: state.orderId!,
                                    name: name,
                                    contact: contact,
                                    email: email,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                        Text('IAP Failed: ${e.toString()}')),
                                  );
                                }
                              } else {
                                await _paymentService.makePayment(
                                  context: context,
                                  amount: state.amount!,
                                  orderId: state.orderId!,
                                  name: name,
                                  contact: contact,
                                  email: email,
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text('Order details missing. Try again later.'),
                                ),
                              );
                            }
                          },
                        ),
          
                        const SizedBox(height: 16),
          
                        if (Platform.isIOS)
                          TextButton(
                            onPressed: () async {
                              final available =
                              await InAppPurchase.instance.isAvailable();
                              if (!available) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'In-app purchases not available.'),
                                  ),
                                );
                                return;
                              }
          
                              try {
                                await InAppPurchase.instance.restorePurchases();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Restoring purchases...'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Restore failed: $e')),
                                );
                              }
                            },
                            child: const Text("Restore Purchases"),
                          ),
          
                        const SizedBox(height: 12),
          
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
          
                        const SizedBox(height: 10),
                        Text(
                          "Note: Your purchase will be verified automatically after payment.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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

class _FeaturePoint extends StatelessWidget {
  final String text;
  const _FeaturePoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2C68EE), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

