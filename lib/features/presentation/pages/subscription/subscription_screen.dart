import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/dashboard/dashboard.dart';

import '../../../../common/widgets/guest_user_restriction.dart';
import '../../../../core/constant/app_vector.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/services/subscription_state_manager.dart';
import '../../../../core/utils/shared_pref_key.dart';
import 'model/subscription_plan_model.dart';

enum LoadingType { trial, purchase }

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final _subscriptionService = SubscriptionPaymentService();

  SubscriptionStatus? _status;
  LoadingType? _loadingType;

  bool _isActionLoading = false;
  bool _loadingPlans = true;

  String? name;
  String? mobile;
  String? email;

  SubscriptionPlan? monthlyPlan;
  SubscriptionPlan? yearlyPlan;
  SubscriptionPlan? selectedPlan;

  // --------------------------------------------------
  // 🔹 Derived state (SINGLE SOURCE OF TRUTH)
  // --------------------------------------------------
  bool get _checkingTrial => _status == null;

  bool get _isSubscribed =>
      _status == SubscriptionStatus.subscribed;

  bool get _canStartTrial =>
      _status == SubscriptionStatus.free;

  bool get _purchaseEnabled =>
      SubscriptionStateManager.canPurchase(_status!) &&
          !_isActionLoading;

  bool get _trialEnabled =>
      SubscriptionStateManager.canStartTrial(_status!) &&
          !_isActionLoading;

  // --------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _loadPlans();
    _loadUserInfo();
  }

  Future<void> _loadStatus() async {
    _status = await SubscriptionStateManager.resolve();
    setState(() {});
  }

  Future<void> _loadUserInfo() async {
    final loginData = await SharedPref.getLoginData();
    setState(() {
      name = loginData?.data?.name;
      email = loginData?.data?.email;
      mobile = loginData?.data?.mobile ?? '';
    });
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _subscriptionService.fetchSubscriptionPlans();
      monthlyPlan = plans.firstWhere((p) => p.planType == 'monthly');
      yearlyPlan = plans.firstWhere((p) => p.planType == 'yearly');
      selectedPlan = monthlyPlan;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _loadingPlans = false);
    }
  }

  // --------------------------------------------------
  // 🔹 ACTIONS
  // --------------------------------------------------

  Future<void> _startPaidSubscription() async {
    if (SharedPref.isGuestUser()) {
      GuestRestrictionDialog.show(context);
      return;
    }

    if (_isSubscribed) return;

    setState(() {
      _isActionLoading = true;
      _loadingType = LoadingType.purchase;
    });

    if (Platform.isIOS) {
      await _subscriptionService.startIosPaidSubscriptionFlow(
        selectedPlan: selectedPlan!,
        onSuccess: _onSubscriptionSuccess,
        onFailure: _handleError,
      );
    } else {
      await _subscriptionService.startAndroidPaidSubscriptionFlow(
        context: context,
        selectedPlan: selectedPlan!,
        name: name!,
        contact: mobile!,
        email: email!,
        onSuccess: _onSubscriptionSuccess,
        onFailure: _handleError,
      );
    }
  }

  Future<void> _startTrialOnly() async {
    if (SharedPref.isGuestUser()) {
      GuestRestrictionDialog.show(context);
      return;
    }

    setState(() {
      _isActionLoading = true;
      _loadingType = LoadingType.trial;
    });

    await _subscriptionService.startIosTrialFlow(
      onSuccess: (msg) async {
        await SharedPref.setBool('trialAvailed', true);
        await SharedPref.setBool('isTrial', true);
        await SharedPref.setBool('isSubscribed', false);
        await SharedPref.setBool(
          SharedPrefKeys.hasPremiumAccess,
          true,
        );

        _status = SubscriptionStatus.trialActive;

        setState(() => _isActionLoading = false);
        CommonMethods.showSnackBar(context, msg);
        _goToDashboard();
      },
      onFailure: _handleError,
    );
  }

  Future<void> _onSubscriptionSuccess(String msg) async {
    await SharedPref.setBool('isSubscribed', true);
    await SharedPref.setBool('isTrial', false);
    await SharedPref.setBool(
      SharedPrefKeys.hasPremiumAccess,
      true,
    );

    _status = SubscriptionStatus.subscribed;

    setState(() => _isActionLoading = false);
    CommonMethods.showSnackBar(context, msg);
    _goToDashboard();
  }

  void _handleError(String err) {
    setState(() {
      _isActionLoading = false;
      _loadingType = null;
    });
    CommonMethods.showSnackBar(context, err);
  }

  void _goToDashboard() {
    gotoRemoveAll(context, const Dashboard());
  }

  // --------------------------------------------------
  // 🔹 UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Color(0xFF93C5FD)),
    );

    return WillPopScope(
      onWillPop: () async {
        _goToDashboard();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF295BBE),
        body: SafeArea(
          child: _checkingTrial
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              children: [
                //_header(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _title(context),
                      const SizedBox(height: 20),
                      _features(),
                      const SizedBox(height: 30),
                      _choosePlanTitle(),
                      const SizedBox(height: 20),
                      _plans(),
                      const SizedBox(height: 30),
                      _comparisonTable(),
                      const SizedBox(height: 20),
                      _promoCodeButton(),
                      const SizedBox(height: 20),
                      _actionButtons(),
                      const SizedBox(height: 10),
                      _restorePurchase(),
                      const SizedBox(height: 8),
                      _browseAppFirst(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // 🔹 SMALL UI HELPERS (UNCHANGED)
  // --------------------------------------------------

  Widget _header() {
    return Container(
      height: 60,
      width: double.infinity,
      color: const Color(0xFF93C5FD),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            child: GestureDetector(
              onTap: _goToDashboard,
              child: const Icon(Icons.close, size: 26),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppVector.noBgLogo, height: 42),
              const SizedBox(width: 8),
              const Text(
                "Tiny Droplets",
                style: TextStyle(
                  fontFamily: "BobbyJones",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return SizedBox(
      height: 48, // keeps layout stable
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ✅ Centered title (never moves)
          const Text(
            "START YOUR FREE TRIAL TODAY!",
            style: TextStyle(
              fontFamily: "BobbyJones",
              fontSize: 20,
              decoration: TextDecoration.underline,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          // ❌ Close button on the right
          Positioned(
            right: -18,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                Navigator.pop(context); // or your custom navigation
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _features() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _featureItem(AppVector.iconRecipes, "500+ Recipes",
            "Meal ideas for every stage and age"),
        _featureItem(AppVector.iconActivities, "Monthly meal plans",
            "Balanced diet chart starting 6 months"),
        _featureItem(AppVector.iconTrackGrowth, "E-books and Guides",
            "Tips on weaning and beyond"),
      ],
    );
  }

  Widget _choosePlanTitle() => const Text(
    "CHOOSE YOUR PLAN",
    style: TextStyle(
      fontFamily: "BobbyJones",
      fontSize: 28,
      decoration: TextDecoration.underline,
      color: Colors.white,
    ),
  );

  Widget _plans() {
    if (_loadingPlans) {
      return const CircularProgressIndicator();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF93C5FD),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(child: _planCard(plan: monthlyPlan!, isYearly: false)),
          const SizedBox(width: 16),
          Expanded(child: _planCard(plan: yearlyPlan!, isYearly: true)),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: _pillButton(
            text: "Purchase plan",
            enabled: _purchaseEnabled,
            isLoading:
            _isActionLoading && _loadingType == LoadingType.purchase,
            onTap: _startPaidSubscription,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _pillButton(
            text: "7 day Trial",
            enabled: _trialEnabled,
            isLoading:
            _isActionLoading && _loadingType == LoadingType.trial,
            onTap: _startTrialOnly,
          ),
        ),
      ],
    );
  }

  Widget _featureItem(String icon, String title, String text) {
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(icon, height: 50),
          const SizedBox(height: 6),

          /// 🔹 Fixed height title box
          SizedBox(
            height: 32, // SAME height for all titles
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _planCard({
    required SubscriptionPlan plan,
    required bool isYearly,
  }) {
    final bool isSelected = selectedPlan?.id == plan.id;

    return GestureDetector(
      onTap: () {
        setState(() => selectedPlan = plan);
      },
      child: AspectRatio( // 👈 makes both cards equal size
        aspectRatio: 1.35,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),

                /// ✅ BACKGROUND BASED ON SELECTION
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [
                    Color(0xFFFFE680),
                    Color(0xFF8BE38B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,

                color: isSelected
                    ? (isYearly ? const Color(0xFFCFE2FF) : null)
                    : const Color(0xFFEAF4FF),

                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF295BBE)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE + RADIO
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isYearly ? "Yearly Plan" : "Monthly Plan",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _selectionIndicator(isSelected),
                    ],
                  ),

                  //const Spacer(),
                  SizedBox(height: 5,),

                  /// PRICE
                  Text(
                    isYearly
                        ? "₹ ${plan.price}/year"
                        : "₹ ${plan.price}/month",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            /// 50% OFF TAG
            if (isYearly)
              Positioned(
                top: -22,
                left: -2,
                right: 10,
                child: Image.asset(
                  AppVector.tag60off,
                  height: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _selectionIndicator(bool isSelected) {
    return Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black),
        color: isSelected ? Colors.black : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }

  // =============================================================
  Widget _comparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F3FE), // Light blue like image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _tableHeaderRow(),

          _tableDivider(),

          _tableRow("Access to 500+ recipes", true, true),
          _tableDivider(),

          _tableRow("Milestones & Activities", true, true),
          _tableDivider(),

          _tableRow("Must-have recommendations", true, true),
          _tableDivider(),

          _tableRow("Monthly meal plans", true, false),
          _tableDivider(),

          _tableRow("Special diet recipes", true, false),
          _tableDivider(),

          _tableRow("Expert-led parenting e-books", true, false),
        ],
      ),
    );
  }

  Widget _tableHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Features",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),

          Expanded(
            child: Text(
              "Pro\nPlans",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              "Basic\nPlans",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableDivider() {
    return Container(
      height: 2,
      color: Colors.white, // Subtle grey-blue divider like design
    );
  }

  Widget _tableRow(String feature, bool pro, bool basic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Row(
        children: [
          /// Feature Text
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          /// Pro Plans Icon
          Expanded(
            child: Center(
              child: Image.asset(
                pro ? AppVector.proCheck : AppVector.basicCross,
                height: 28,
              ),
            ),
          ),

          /// Basic Plans Icon
          Expanded(
            child: Center(
              child: Image.asset(
                basic ? AppVector.proCheck : AppVector.basicCross,
                height: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  Widget _promoCodeButton() {
    return Column(
      children: [
        Text(
          "I have a promo code",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),

        /// Underline bar (not TextDecoration)
        Container(
          width: 180,
          height: 2,
          color: Colors.white,
        ),
      ],
    );
  }

  // =============================================================
  // Widget _actionButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _pillButton(
  //           text: "Purchase plan",
  //           enabled: _purchaseEnabled,
  //           isLoading:
  //           _isActionLoading && _loadingType == LoadingType.purchase,
  //           onTap: () {
  //             setState(() {
  //               _isActionLoading = true;
  //               _loadingType = LoadingType.purchase;
  //             });
  //             _startPaidSubscription();
  //           },
  //         ),
  //       ),
  //       const SizedBox(width: 14),
  //       Expanded(
  //         child: _pillButton(
  //           text: "7 day Trial",
  //           enabled: _trialEnabled,
  //           isLoading: _isActionLoading && _loadingType == LoadingType.trial,
  //           onTap: () {
  //             setState(() {
  //               _isActionLoading = true;
  //               _loadingType = LoadingType.trial;
  //             });
  //             _startTrialOnly();
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _pillButton({
    required String text,
    required bool enabled,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled && !isLoading ? onTap : null,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: enabled
              ? const LinearGradient(
            colors: [
              Color(0xFF7CF2D6),
              Color(0xFF4FD1C5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: enabled ? null : Colors.grey.shade300,
          border: Border.all(
            color: enabled ? Colors.white : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.black : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }



  Widget _restorePurchase() {
    return Column(
      children: [
        Text(
          "Restore purchase",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 180,
          height: 2,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _browseAppFirst() {
    return GestureDetector(
      onTap: () => gotoRemoveAll(context, Dashboard()),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "Not Now, Browse App First",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 220,
            height: 2,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
