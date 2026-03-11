import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/presentation/pages/remove_ads/bloc/remove_ads_cubit.dart';
import '../../constant/app_export.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  bool shouldShowAds(BuildContext context) {
    try {
      final removeAdsCubit = context.read<RemoveAdsCubit>();
      final state = removeAdsCubit.state;
      return !state.isPurchased;
    } catch (e) {
      debugPrint('Error checking ad status: $e');
      return true;
    }
  }

  void checkAdStatus(BuildContext context) {
    try {
      context.read<RemoveAdsCubit>().checkUserRemovedAds();
    } catch (e) {
      debugPrint('Error refreshing ad status: $e');
    }
  }
}