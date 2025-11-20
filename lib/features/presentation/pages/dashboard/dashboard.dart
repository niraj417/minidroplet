import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_list/ebook_page.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/feed_page.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/my_account.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_page.dart';
import '../../../../core/theme/theme_bloc/theme_bloc.dart';
import '../../../../core/theme/theme_bloc/theme_state.dart';
import 'dashboard_bloc/dashboard_bloc.dart';
import 'dashboard_bloc/dashboard_event.dart';
import 'dashboard_bloc/dashboard_state.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<Widget> screens = [
    const FeedPage(),
    const EbookPage(),
    VideoPage(),
    const MyAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final currentIndex =
            state is DashboardNavigationState ? state.currentIndex : 0;

        final themeState = context.watch<ThemeBloc>().state;
        final Color activeIconColor =
            themeState is DarkThemeState ? Colors.white : Colors.white;
        final Color inactiveIconColor =
            themeState is DarkThemeState ? Colors.white : Colors.black;
        final Color buttonBackgroundColor =
            themeState is DarkThemeState ? Colors.black : Colors.white;

        return PopScope(
          canPop: false, // Prevent system navigation
          onPopInvoked: (didPop) async {
            if (currentIndex != 0) {
              context.read<DashboardBloc>().add(NavigateToIndex(0));
            } else {
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exit App',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      const Text('Do you want to exit the app?',
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );

              if (shouldExit ?? false) {
                SystemNavigator.pop();
              }
            }
          },
          child: Scaffold(
            extendBody: true,
            body: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
              child: CurvedNavigationBar(
                index: currentIndex,
                items: [
                  Icon(
                    Icons.feed,
                    size: 30,
                    color:
                        currentIndex == 0 ? activeIconColor : inactiveIconColor,
                  ),
                  Icon(
                    Icons.menu_book_rounded,
                    size: 30,
                    color:
                        currentIndex == 1 ? activeIconColor : inactiveIconColor,
                  ),
                  Icon(
                    CupertinoIcons.videocam_fill,
                    size: 30,
                    color:
                        currentIndex == 2 ? activeIconColor : inactiveIconColor,
                  ),
                  Icon(
                    CupertinoIcons.person,
                    size: 30,
                    color:
                        currentIndex == 3 ? activeIconColor : inactiveIconColor,
                  ),
                ],
                onTap: (index) {
                  if (index != currentIndex) {
                    context.read<DashboardBloc>().add(NavigateToIndex(index));
                  }
                },
                height: 60,
                color: buttonBackgroundColor,
                buttonBackgroundColor: Color(AppColor.primaryColor),
                backgroundColor: Colors.transparent,
                animationCurve: Curves.easeInOut,
                animationDuration: const Duration(milliseconds: 200),
              ),
            ),
          ),
        );
      },
    );
  }
}
