import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/course_page/course_page.dart';
import 'package:tinydroplets/features/presentation/pages/ebook_page/ebook_list/ebook_page.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/feed_page.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/my_account.dart';
import 'package:tinydroplets/features/presentation/pages/video_page/video_page.dart';
import '../../../../core/theme/theme_bloc/theme_bloc.dart';
import '../../../../core/theme/theme_bloc/theme_state.dart';
import '../my_account/profile_bloc/profile_cubit.dart';
import 'dashboard_bloc/dashboard_bloc.dart';
import 'dashboard_bloc/dashboard_event.dart';
import 'dashboard_bloc/dashboard_state.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLowEndDevice = false;
  final Map<int, Widget> _screenCache = {};

  @override
  void initState() {
    super.initState();
    _screenCache[0] = _buildScreen(0);
    _detectLowEndDevice();
  }

  Future<void> _detectLowEndDevice() async {
    try {
      bool isLowEnd = false;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        isLowEnd =
            androidInfo.isLowRamDevice || androidInfo.physicalRamSize <= 4096;
      } else if (Platform.isIOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        isLowEnd = iosInfo.physicalRamSize <= 3072;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isLowEndDevice = isLowEnd;
        if (isLowEnd) {
          final homeScreen = _screenCache[0] ?? _buildScreen(0);
          _screenCache
            ..clear()
            ..[0] = homeScreen;
        }
      });
    } catch (e) {
      debugPrint('Dashboard low-end detection failed: $e');
    }
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const FeedPage();
      case 1:
        return const CourseListPage();
      case 2:
        return const EbookPage();
      case 3:
        return VideoPage();
      case 4:
        return BlocProvider(
          create: (_) => ProfileCubit(),
          child: const MyAccount(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _getScreen(int index) {
    if (_isLowEndDevice) {
      _screenCache
        ..clear()
        ..[index] = _buildScreen(index);
      return _screenCache[index]!;
    }

    return _screenCache.putIfAbsent(index, () => _buildScreen(index));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final currentIndex =
            state is DashboardNavigationState ? state.currentIndex : 0;

        context.watch<ThemeBloc>(); // still watch so widget rebuilds on theme change
        final isDark = Theme.of(context).brightness == Brightness.dark;
        const Color activeIconColor = Colors.white;
        final Color inactiveIconColor = isDark ? Colors.white : Colors.black;
        final Color buttonBackgroundColor = isDark ? Colors.black : Colors.white;

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
            extendBody: false,
            body:
                _isLowEndDevice
                    ? KeyedSubtree(
                      key: ValueKey(currentIndex),
                      child: _getScreen(currentIndex),
                    )
                    : IndexedStack(
                      index: currentIndex,
                      children: List<Widget>.generate(
                        5,
                        _getScreen,
                        growable: false,
                      ),
                    ),
            bottomNavigationBar: Container(
              color: buttonBackgroundColor, // matches nav bar, fills iOS safe area gap
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
                  Icons.ondemand_video_outlined,
                  size: 30,
                  color:
                  currentIndex == 1 ? activeIconColor : inactiveIconColor,
                ),
                Icon(
                  Icons.menu_book_rounded,
                  size: 30,
                  color:
                      currentIndex == 2 ? activeIconColor : inactiveIconColor,
                ),
                Icon(
                  CupertinoIcons.videocam_fill,
                  size: 30,
                  color:
                      currentIndex == 3 ? activeIconColor : inactiveIconColor,
                ),
                Icon(
                  CupertinoIcons.person,
                  size: 30,
                  color:
                      currentIndex == 4 ? activeIconColor : inactiveIconColor,
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
