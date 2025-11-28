import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tinydroplets/common/widgets/app_button.dart';

import '../bloc/remove_ads_cubit.dart';
import '../bloc/remove_ads_state.dart';

class PurchaseDetailsBottomSheet extends StatelessWidget {
  const PurchaseDetailsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<RemoveAdsCubit, RemoveAdsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Format the expiry date if available
              String formattedDate = 'Not available';
              if (state.expiryDate != null) {
                try {
                  final DateTime expiry = DateTime.parse(state.expiryDate!);
                  formattedDate = DateFormat('MMM dd, yyyy').format(expiry);
                } catch (e) {
                  formattedDate = state.expiryDate!;
                }
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
                  const Icon(Icons.verified, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Ad-Free Status Active',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoRow(
                    context,
                    'Transaction ID',
                    state.transactionId ?? 'Not available',
                  ),
                  const Divider(),
                  _buildInfoRow(context, 'Expiry Date', formattedDate),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    'Status',
                    'Active',
                    valueColor: Colors.green,
                  ),

                  AppButton(
                    text: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      String label,
      String value, {
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}