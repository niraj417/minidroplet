import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/model/order_history_model.dart';
import '../../../../core/constant/app_export.dart';
import 'order_history_bloc/order_history_cubit.dart';
import 'package:flutter/material.dart';



class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderListCubit _orderListCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _orderListCubit = OrderListCubit();
    _orderListCubit.fetchOrderHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _orderListCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'eBooks'),
              Tab(text: 'Videos'),
              Tab(text: 'Playlists'),
            ],
          ),
        ),
        body: BlocConsumer<OrderListCubit, OrderListState>(
          listener: (context, state) {
            if (state is OrderListError) {
              CommonMethods.showSnackBar(context, state.message);
            } else if (state is DownloadError) {
              CommonMethods.showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is OrderListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderListLoaded ||
                (state is DownloadProgress && state.currentState is OrderListLoaded) ||
                (state is DownloadingPdf && state.currentState is OrderListLoaded) ||
                (state is PermissionRequired && state.currentState is OrderListLoaded)) {

              // Get the actual data state
              OrderListLoaded dataState;
              if (state is OrderListLoaded) {
                dataState = state;
              } else if (state is DownloadProgress) {
                dataState = state.currentState as OrderListLoaded;
              } else if (state is DownloadingPdf) {
                dataState = state.currentState as OrderListLoaded;
              } else {
                dataState = (state as PermissionRequired).currentState as OrderListLoaded;
              }

              // Check if there's an active download
              double? downloadProgress;
              if (state is DownloadProgress) {
                downloadProgress = state.progress;
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  // eBooks Tab
                  _buildContentList(
                    context,
                    dataState.ebooks,
                    'ebook',
                    downloadProgress,
                  ),

                  // Videos Tab
                  _buildContentList(
                    context,
                    dataState.videos,
                    'video',
                    downloadProgress,
                  ),

                  // Playlists Tab
                  _buildContentList(
                    context,
                    dataState.playlists,
                    'playlist',
                    downloadProgress,
                  ),
                ],
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load orders'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<OrderListCubit>().fetchOrderHistory(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildContentList(BuildContext context, List<Ebook> items, String type, double? downloadProgress) {
    if (items.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'ebook' ? Icons.book : type == 'video' ? Icons.video_library : Icons.playlist_play,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text('No $type orders found'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<OrderListCubit>().fetchOrderHistory(),
            child: const Text('Refresh'),
          ),
        ],
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Theme.of(context).cardColor,
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: item.coverImage != null && item.coverImage!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.coverImage!,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, _) => Container(
                  width: 60,
                  height: 80,
                  color: Colors.grey[300],
                  child: Icon(
                    type == 'ebook' ? Icons.book : type == 'video' ? Icons.video_library : Icons.playlist_play,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
                : Container(
              width: 60,
              height: 80,
              color: Colors.grey[300],
              child: Icon(
                type == 'ebook' ? Icons.book : type == 'video' ? Icons.video_library : Icons.playlist_play,
                color: Colors.grey[600],
              ),
            ),
            title: Text(
              item.title ?? 'Untitled',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${item.orderId ?? 'N/A'}'),
                Text('Transaction: ${item.transactionId ?? 'N/A'}'),
                Text('Date: ${item.createdAt ?? 'N/A'}'),
                Text('Amount: ₹${item.amount ?? 'N/A'}'),
              ],
            ),
            trailing: downloadProgress != null
                ? CircularProgressIndicator(value: downloadProgress)
                : IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Always show download icon and handle empty invoice links in the cubit
                context.read<OrderListCubit>().downloadPdf(
                  item.invoiceLink ?? '',
                  'receipt_${item.id}_${item.title?.replaceAll(' ', '_')}',
                  context,
                );
              },
            ),
          ),
        );
      },
    );
  }
}