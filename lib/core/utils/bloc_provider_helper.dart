import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/core/services/ad_service/ad_bloc/ad_cubit.dart';
import 'package:tinydroplets/core/theme/theme_bloc/theme_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_completion/profile_completion_cubit.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/bloc/all_ingredient_bloc/all_ingredient_cubit.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/bloc/feed_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/bloc/track_milestone_bloc/track_milestone_cubit.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_bloc/profile_state.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/bloc/ingredient_detail_bloc/ingredient_detail_cubit.dart';
import '../../features/presentation/pages/dashboard/dashboard_bloc/dashboard_bloc.dart';
import '../../features/presentation/pages/ebook_page/ebook_list/bloc/ebook_bloc.dart';
import '../../features/presentation/pages/ebook_page/ebook_list/bloc/ebook_state.dart';
import '../../features/presentation/pages/ebook_page/search_ebook/bloc/search_bloc.dart';
import '../../features/presentation/pages/feed_page/bloc/affiliate_bloc/affiliate_cubit.dart';
import '../../features/presentation/pages/feed_page/bloc/age_group_bloc/age_group_cubit.dart';
import '../../features/presentation/pages/feed_page/bloc/feed_activity_bloc/feed_activity_cubit.dart';
import '../../features/presentation/pages/my_account/profile_bloc/profile_cubit.dart';
import '../../features/presentation/pages/my_account/saved_bloc/saved_cubit.dart';
import '../../features/presentation/pages/notification_page/notification_page.dart';
import '../../features/presentation/pages/remove_ads/bloc/remove_ads_cubit.dart';
import '../network/api_controller.dart';
import '../services/internet_connectivity/internet_cubit.dart';

class BlocProviderHelper extends StatelessWidget {
  final Widget child;
  const BlocProviderHelper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(create: (_) => DashboardBloc()),
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
        BlocProvider<FeedBloc>(
          create:
              (context) =>
                  FeedBloc()
                    ..add(FeedCarouselData())
                    ..add(FeedPostData())
                    ..add(FeedPlaylistData())
                    ..add(FeedHomepageCarouselData()),
        ),
        BlocProvider(
          create:
              (context) =>
                  EbookBloc()
                    ..add(FetchEbookCarouselData())
                    ..add(FetchAllEbookData())
                    ..add(FetchRecentlyViewedEbookData())
                    ..add(FetchEbookPageCarouselsData()),
        ),
        BlocProvider(create: (context) => SearchEbookBloc()),

        // BlocProvider<VideoBloc>(create: (context) => VideoBloc(),),
        // BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider(
          create: (context) => InternetCubit(),
        ), //  BlocProvider(create: (_) => NotificationCubit()),
        BlocProvider(create: (context) => SavedItemsCubit()..loadInitialData()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => AdCubit(DioClient())..checkAdsStatus()),
        BlocProvider(create: (_) => AgeGroupCubit()..fetchAgeGroup()),
        BlocProvider(create: (_) => TrackMilestoneCubit()),
        BlocProvider(create: (_) => AffiliateCubit()),
        BlocProvider(create: (_) => IngredientCubit(dioClient)),
        BlocProvider(create: (_) => IngredientDetailCubit(dioClient)),
        BlocProvider(create: (_) => RemoveAdsCubit(dioClient: dioClient)),
        BlocProvider(create: (_) => FeedActivityCubit(DioClient())),
        BlocProvider(create: (_) => ProfileCompletionCubit()),
      ],
      child: child,
    );
  }
}
