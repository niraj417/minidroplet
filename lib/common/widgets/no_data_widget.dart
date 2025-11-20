import 'package:flutter/cupertino.dart';

import '../../core/constant/app_export.dart';

class NoDataWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const NoDataWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.arrow_clockwise, size: 48, color: Colors.grey),
          const Text('No item available'),
          SizedBox(height: 10),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Color(AppColor.primaryColor),
              ),
            ),
            onPressed: onPressed,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

//
// return Center(child: Column(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// Icon(
// type == 'ebook' ? Icons.book : type == 'video' ? Icons.video_library : Icons.playlist_play,
// size: 48,
// color: Colors.grey,
// ),
// const SizedBox(height: 16),
// Text('No $type orders found'),
// const SizedBox(height: 16),
// ElevatedButton(
// onPressed: () => context.read<OrderListCubit>().fetchOrderHistory(),
// child: const Text('Refresh'),
// ),
// ],
// ));
