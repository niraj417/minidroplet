import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinydroplets/core/services/notification_services.dart';
import 'package:tinydroplets/core/services/payment_service.dart';
import 'package:tinydroplets/core/theme/theme_bloc/theme_bloc.dart';
import 'package:tinydroplets/core/theme/theme_bloc/theme_event.dart';
import 'package:tinydroplets/core/utils/shared_pref_key.dart';
import 'package:tinydroplets/features/presentation/pages/auth/login_page/login_page.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/account.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/orders_page.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/privacy_policy_screen.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_bloc/profile_cubit.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_bloc/profile_state.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_completion/profile_completion_cubit.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_page.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/saved_item_screen.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/widget/profile_item.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/widget/social_link_scroll.dart';
import 'package:tinydroplets/features/presentation/pages/subscription/subscription_screen.dart';

import '../../../../common/widgets/guest_user_restriction.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/services/internet_connectivity/internet_cubit.dart';
import '../../../../core/services/internet_connectivity/internet_state.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/theme/theme_bloc/theme_state.dart';
import '../dashboard/dashboard_bloc/dashboard_bloc.dart';
import '../dashboard/dashboard_bloc/dashboard_event.dart';
import '../remove_ads/bloc/remove_ads_cubit.dart';
import '../remove_ads/bloc/remove_ads_state.dart';
import '../remove_ads/widget/purchase_details_bottom_sheet.dart';
import '../remove_ads/widget/remove_ads_bottom_sheet.dart';
import 'model/cms_model.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  String _appVersion = "Loading...";
  final _dioClient = DioClient();
  bool isSubscribed = false;
  CmsModel? cmsModel;
  final SubscriptionPaymentService _subscriptionPayment = SubscriptionPaymentService();

  @override
  void initState() {
    super.initState();
    checkStatus();
    _loadAppVersion();
    _loadNotificationState();
    //getUserProfile();
    _getCms();
  }

  Future<void> _loadNotificationState() async {

    setState(() {
      _disableNotification =
          SharedPref.getBool(SharedPrefKeys.notificationDisabled) ?? false;
    });
  }

  Future<void> checkStatus() async {
    try{
      isSubscribed = await SubscriptionPaymentService.hasActiveSubscription();
    } catch(e){
      print("check Status error : ${e.toString()}");
    }
  }


  @override
  void dispose(){
    _subscriptionPayment.dispose();
    super.dispose();
  }
  // String name = '';
  // String email = '';
  // String image = '';
  //
  // void getUserProfile() async {
  //   var data = await SharedPref.getLoginData();
  //   setState(() {
  //     name = data!.data!.name;
  //     email = data.data!.email;
  //     image = data.data!.profile;
  //   });
  //   print("User Profile Data : $name , $email ");
  // }

  Future<void> _getCms() async {
    try {
      final response = await dioClient.sendGetRequest(ApiEndpoints.cms);
      if (response.data['status'] == 1) {
        setState(() {
          cmsModel = CmsModel.fromJson(response.data);
        });
      }
    } catch (e) {
      if (mounted) {
        CommonMethods.showSnackBar(context, e.toString());
      }
    }
  }

  void _showSnack() {
    CommonMethods.showSnackBar(context, 'Not available');
  }

  void _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      CommonMethods.devLog(logName: 'Error', message: e.toString());
    }
  }

  bool isDarkMode = false;
  bool _disableNotification = false;

  Future<void> _toggleNotification() async {
    final prefs = await SharedPreferences.getInstance();

    final newValue = !_disableNotification;

    setState(() {
      _disableNotification = newValue;
    });

    await prefs.setBool(SharedPrefKeys.notificationDisabled, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetCubit, InternetState>(
        listener: (context, state) {
          if (state is InternetConnected) {

            /// Reload ebooks when internet comes back
            context.read<ProfileCubit>().loadProfile();

          }
        },
        child: Scaffold(
          //   appBar: CustomAppBar(title: 'My Account'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),

                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                          if (state.isProfileLoading) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text(
                                  "Loading profile...",
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            height: 120,
                            width: 120,
                            clipBehavior: Clip.hardEdge,
                            child: CustomImage(imageUrl: state.image),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: -23,
                        child: Transform.rotate(
                          angle: 44.4,
                          child: IconButton(
                            onPressed: () async {
                              if(SharedPref.isGuestUser()){
                                GuestRestrictionDialog.show(context);
                              } else{
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                                );

                                if (result == true) {
                                  context.read<ProfileCubit>().loadProfile();
                                }
                              }
                            },
                            icon: Icon(CupertinoIcons.pencil_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state.isProfileLoading) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          // CircularProgressIndicator(),
                          SizedBox(height: 12),
                          // Text(
                          //   "Loading profile...",
                          //   style: TextStyle(fontSize: 14, color: Colors.grey),
                          // ),
                        ],
                      );
                    }
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            state.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            state.email,
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 24),
                // Divider
                Divider(color: Colors.grey),

                ListTile(
                  leading: Icon(CupertinoIcons.brightness),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  trailing: BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return CupertinoSwitch(
                        activeTrackColor: AppColor.grey,
                        thumbColor:
                            state is LightThemeState
                                ? Colors.white
                                : Color(AppColor.primaryColor),
                        value: context.read<ThemeBloc>().state is DarkThemeState,
                        onChanged: (bool value) {
                          context.read<ThemeBloc>().add(ToggleThemeEvent());
                        },
                      );
                    },
                  ),
                ),

                // Divider
                Divider(color: Colors.grey),

                ListTile(
                  leading: Icon(CupertinoIcons.lock),
                  title: Text(
                    'Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  onTap: () => goto(context, Account()),
                ),

                Divider(color: Colors.grey),
                ListTile(
                  leading: Icon(CupertinoIcons.bell),
                  title: Text(
                    'Notification',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  onTap: _toggleNotification,
                  trailing: Icon(
                    _disableNotification
                        ? CupertinoIcons.bell
                        : CupertinoIcons.bell_slash,
                  ),
                ),

                Divider(color: Colors.grey),
                BlocBuilder<RemoveAdsCubit, RemoveAdsState>(
                  builder: (context, state) {
                    return ProfileItem(
                      icon: CupertinoIcons.money_dollar_circle,
                      //title: state.isPurchased ? 'Ad-Free Status' : 'Remove Ads',
                      title: "Subscription",
                      onTap: () {
                        goto(context, SubscriptionPage());
                        // if (state.isPurchased || isSubscribed) {
                        //   _showPurchaseDetailsBottomSheet(context);
                        // } else {
                        //   _showRemoveAdsBottomSheet(context);
                        // }
                      },
                    );
                  },
                ),
                Divider(color: Colors.grey),
                ProfileItem(
                  icon: CupertinoIcons.bookmark,
                  title: 'Saved',
                  onTap: () => goto(context, SavedItemsScreen()),
                ),
                // Divider(color: Colors.grey),
                // ProfileItem(
                //   icon: CupertinoIcons.purchased,
                //   title: 'Purchases',
                //   onTap: () => goto(context, OrderListScreen()),
                // ),

                Column(
                  children: [
                    Divider(color: Colors.grey),
                    ProfileItem(
                      icon: CupertinoIcons.lock_shield,
                      title: 'Privacy Policy',
                      onTap:
                          cmsModel == null
                              ? _showSnack
                              : () => goto(
                                context,
                                CmsScreen(
                                  title: cmsModel?.data?.privacyPolicy?.title ?? '',
                                  description:
                                      cmsModel?.data?.privacyPolicy?.description ??
                                      '',
                                ),
                              ),
                    ),
                    Divider(color: Colors.grey),
                    ProfileItem(
                      icon: CupertinoIcons.book,
                      title: 'Term & Conditions',
                      onTap:
                          cmsModel == null
                              ? _showSnack
                              : () => goto(
                                context,
                                CmsScreen(
                                  title:
                                      cmsModel?.data?.termsConditions?.title ?? '',
                                  description:
                                      cmsModel
                                          ?.data
                                          ?.termsConditions
                                          ?.description ??
                                      '',
                                ),
                              ),
                    ),
                    Divider(color: Colors.grey),
                    ProfileItem(
                      icon: CupertinoIcons.person_2,
                      title: 'Contact us',
                      onTap:
                          cmsModel == null
                              ? _showSnack
                              : () => goto(
                                context,
                                CmsScreen(
                                  title: cmsModel?.data?.contactUs?.title ?? '',
                                  description:
                                      cmsModel?.data?.contactUs?.description ?? '',
                                ),
                              ),
                    ),
                    Divider(color: Colors.grey),
                    ProfileItem(
                      icon: CupertinoIcons.info_circle,
                      title: 'About us',
                      onTap:
                          cmsModel == null
                              ? _showSnack
                              : () => goto(
                                context,
                                CmsScreen(
                                  title: cmsModel?.data?.aboutUs?.title ?? '',
                                  description:
                                      cmsModel?.data?.aboutUs?.description ?? '',
                                ),
                              ),
                    ),
                    Divider(color: Colors.grey),
                  ],
                ),

                // ProfileItem(
                //   icon: CupertinoIcons.square_arrow_right,
                //   title: 'Log Out',
                //   onTap: () async {
                //     CommonMethods.showSnackBar(context, 'Logout successfully');
                //     Future.delayed(Duration(milliseconds: 200), () async {
                //       final removed = await SharedPref.removeLoginData();
                //       await SharedPref.resetAllData();
                //       CommonMethods.devLog(logName: 'Logout', message: removed);
                //
                //       if (context.mounted) {
                //         context.read<ProfileCubit>().reset();
                //         context.read<ProfileCompletionCubit>().reset();
                //         Future.delayed(Duration(seconds: 2));
                //
                //         Navigator.pushAndRemoveUntil(
                //           context,
                //           MaterialPageRoute(builder: (_) => const LoginPage()),
                //           (route) => false,
                //         );
                //
                //         context.read<DashboardBloc>().add(ResetNavigation());
                //         CommonMethods.showSnackBar(context, 'Logout successfully');
                //       }
                //     });
                //   },
                // ),
                ProfileItem(
                  icon: CupertinoIcons.square_arrow_right,
                  title: 'Log Out',
                  onTap: () async {
                    try {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                      }

                      final removed = await SharedPref.removeLoginData();
                      CommonMethods.devLog(
                        logName: 'Logout',
                        message: 'Login data removed: $removed',
                      );

                      await SharedPref.resetAllDataExceptSettings();

                      if (context.mounted) {
                        context.read<ProfileCubit>().reset();
                        context.read<ProfileCompletionCubit>().reset();
                        context.read<DashboardBloc>().add(ResetNavigation());

                        ScaffoldMessenger.of(context).clearSnackBars();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      CommonMethods.devLog(
                        logName: 'Logout Error',
                        message: e.toString(),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        CommonMethods.showSnackBar(
                          context,
                          'Logout failed. Please try again.',
                        );
                      }
                    }
                  },
                ),

                Divider(color: Colors.grey),
                //   SizedBox(height: 10),
                ProfileItem(
                  icon: CupertinoIcons.globe,
                  title: 'Follow Us',
                  onTap: () {},
                ),
                SocialLinksScroll(),
                Divider(color: Colors.grey),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.app, color: Colors.grey[600], size: 18),
                    SizedBox(width: 8),
                    Text(
                      'App Version: $_appVersion',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
    );
  }

  void _showRemoveAdsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RemoveAdsBottomSheet(),
    );
  }

  void _showPurchaseDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PurchaseDetailsBottomSheet(),
    );
  }
}
