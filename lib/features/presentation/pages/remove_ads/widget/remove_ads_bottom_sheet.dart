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
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<RemoveAdsCubit, RemoveAdsState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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

              return Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Remove Ads',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.description ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  if (state.amount != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Price: ₹${state.amount}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  AppButton(
                    text: 'Subscribe to Remove Ads',
                    onPressed: () async {
                      if (state.amount != null && state.orderId != null) {
                        final prefData = SharedPref.getLoginData();
                        final name = prefData?.data?.name ?? '';
                        final contact = prefData?.data?.mobile ?? '';
                        final email = prefData?.data?.email ?? '';

                        if (Theme.of(context).platform == TargetPlatform.iOS) {
                          // iOS: Use In-App Purchase
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
                                content: Text('IAP Failed: ${e.toString()}'),
                              ),
                            );
                          }
                        } else {
                          // Android: Use Razorpay
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
                            content: Text(
                              'Order details missing. Try again later.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final available =
                            await InAppPurchase.instance.isAvailable();
                        if (!available) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('In-app purchases not available.'),
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
                            SnackBar(content: Text('Restore failed: $e')),
                          );
                        }
                      },
                      child: const Text('Restore Purchases'),
                    ),
                  ],

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  const Text(
                    'Note: After successful payment, your purchase will be automatically verified.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
