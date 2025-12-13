import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/dashboard/dashboard.dart';
import 'package:tinydroplets/features/presentation/pages/subscription/widget/quote_border_painter.dart';

import '../../../../core/constant/app_vector.dart';
import '../../../../core/services/subscription_service.dart';
import 'model/subscription_plan_model.dart';

class SubscriptionPage extends StatefulWidget {
  SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {

  bool _trialLoading = false;

  String? name;
  String? mobile;
  String? email;

  final _subscriptionService = SubscriptionPaymentService();

  SubscriptionPlan? monthlyPlan;
  SubscriptionPlan? yearlyPlan;
  SubscriptionPlan? selectedPlan;

  bool _loadingPlans = true;

  bool _canStartTrial = false;
  bool _checkingTrial = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadTrialStatus();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _subscriptionService.fetchSubscriptionPlans();

      monthlyPlan =
          plans.firstWhere((p) => p.planType == 'monthly');
      yearlyPlan =
          plans.firstWhere((p) => p.planType == 'yearly');

      /// Default selected = Monthly
      selectedPlan = monthlyPlan;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _loadingPlans = false;
      });
    }
  }

  Future<void> _loadTrialStatus() async {
    final loginData = await SharedPref.getLoginData();

    setState(() {
      name = loginData?.data!.name;
      email = loginData?.data?.email;
      mobile = loginData?.data?.mobile ?? '';
      _canStartTrial = (loginData?.data?.trialAvailed ?? 1) == 0;
      _checkingTrial = false;
    });
  }

  String get _buttonText {
    if (_canStartTrial) {
      return 'Continue booking ${selectedPlan?.name ?? "loading.."}';
    }
    return 'Start 7-day free trial';
  }

  Future<bool?> _showTrialChoiceSheet() {
    String? selected;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ─── HEADER ───────────────────────────
                    Row(
                      children: [
                        Text(
                          "Subscription",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// ─── OPTION 1: FREE TRIAL ─────────────
                    _subscriptionOptionCard(
                      title: "1-week free trial",
                      subtitle: "Try premium features free",
                      price: "₹0 for 7 days",
                      selected: selected == "trial",
                      onTap: () {
                        setSheetState(() => selected = "trial");
                      }
                    ),

                    const SizedBox(height: 12),

                    /// ─── OPTION 2: PAID PLAN ─────────────
                    _subscriptionOptionCard(
                      title: "${selectedPlan!.name}",
                      subtitle: "Full access, cancel anytime",
                      price:
                      "₹${selectedPlan!.price} / ${selectedPlan!.planType}",
                      selected: selected == "paid",
                      onTap: () =>
                          setSheetState(() => selected = "paid"),
                    ),

                    const SizedBox(height: 18),

                    /// ─── CONTINUE BUTTON ─────────────────
                    GestureDetector(
                      onTap: selected == null
                          ? null
                          : () {
                        if(selected == "trial"){
                          //Navigator.pop(context, true); // 👈 selected trial
                          _startTrialOnly();
                        } else {
                          //Navigator.pop(context, true); // 👈 selected paid
                          _startPaidSubscription();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected == null
                              ? Colors.grey.shade300
                              : Colors.black,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Continue",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: selected == null
                                  ? Colors.grey.shade600
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _startPaidSubscription() async {
    Navigator.pop(context);

    setState(() => _trialLoading = true);

    if(Platform.isIOS){
      await _subscriptionService.startIosPaidSubscriptionFlow(
        selectedPlan: selectedPlan!,
        onSuccess: (msg) {
          setState(() => _trialLoading = false);
          CommonMethods.showSnackBar(context, msg);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Dashboard()),
          );
        },
        onFailure: (err) {
          setState(() => _trialLoading = false);
          CommonMethods.showSnackBar(context, err);
        },
      );
    } else {
      _subscriptionService.amount = selectedPlan!.price;
      _subscriptionService.startAndroidPaidSubscriptionFlow(
        context: context,
        selectedPlan: selectedPlan!,
        name: name!,
        contact: mobile!,
        email: email!,
        onSuccess: (msg) {
          setState(() => _trialLoading = false);
          CommonMethods.showSnackBar(context, msg);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Dashboard()),
          );
        },
        onFailure: (err) {
          setState(() => _trialLoading = false);
          CommonMethods.showSnackBar(context, err);
        },
      );
    }
  }


  Future<void> _startTrialOnly() async {
    Navigator.pop(context);

    try {
      setState(() => _trialLoading = true);

      await _subscriptionService.startIosTrialFlow(
        onSuccess: (msg) {
          setState(() => _trialLoading = false);
          CommonMethods.showSnackBar(context, msg);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Dashboard()),
          );
        },
        onFailure: (err) {
          setState(() => _trialLoading = false);
          CommonMethods.showSnackBar(context, err);
        },
      );
    } catch (e) {
      CommonMethods.showSnackBar(context, e.toString());
    } finally {
      setState(() => _trialLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color(0xFF93C5FD),
    ));
    return Scaffold(
      backgroundColor: const Color(0xFF295BBE),
      body: SafeArea(
        child: _checkingTrial ? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
          child: Column(
            children: [
              /// LOGO
              Container(
                  height: 60,
                  width: double.infinity,
                  color: Color(0xFF93C5FD),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppVector.noBgLogo, height: 60),
                      SizedBox(width: 10,),
                      Text(
                        "Tiny Droplets",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "BobbyJones",
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //const SizedBox(height: 20),

                    const SizedBox(height: 20),

                    /// TITLE
                    Text(
                      "START YOUR FREE TRIAL TODAY!",
                      style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        decorationThickness: 2,
                        fontFamily: "BobbyJones",
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    /// THREE FEATURES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _featureItem(AppVector.iconRecipes, "500+ Recipes" ,"Meal ideas for every stage and age"),
                        _featureItem(AppVector.iconActivities, "Monthly meal plans","Balanced diet chart starting 6 months"),
                        _featureItem(AppVector.iconTrackGrowth, "E-books and Guides", "Tips on weaning and beyond "),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// CHOOSE YOUR PLAN TITLE
                    Text(
                      "CHOOSE YOUR PLAN",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// MONTHLY + YEARLY CARDS (NEW DESIGN)
                    _loadingPlans ? const Center(child: CircularProgressIndicator()) :
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF93C5FD), // Light sky blue background
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _monthlyPlanCardStyled(monthlyPlan!)),
                          const SizedBox(width: 16),
                          Expanded(child: _yearlyPlanCardStyled(yearlyPlan!)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// PRO VS BASIC TITLE
                    Text(
                      "PRO PLANS VS BASIC PLANS",
                      style: TextStyle(
                        fontFamily: "BobbyJones",
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,

                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Find the right plan for your baby’s nutrition and growth needs",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    /// COMPARISON TABLE
                    _comparisonTable(),

                    const SizedBox(height: 20),

                    /// PROMO CODE BUTTON
                    _promoCodeButton(),

                    const SizedBox(height: 20),

                    /// FREE TRIAL BUTTON
                    _startFreeTrialButton(
                      isLoading: _trialLoading,
                      onTap: () async {
                        try {
                          setState(() => _trialLoading = true);

                          if(_canStartTrial) {
                            final result = await _showTrialChoiceSheet();
                            if (result != true) {
                              // Bottom sheet dismissed without selection
                              setState(() => _trialLoading = false);
                            }
                          } else {
                            _startPaidSubscription();
                          }
                        } catch (e) {
                          setState(() => _trialLoading = false);

                          CommonMethods.showSnackBar(
                            context,
                            e.toString().replaceAll('Exception:', ''),
                          );
                        }
                      },
                    ),


                    const SizedBox(height: 10),

                    /// Restore purchase
                    _restorePurchase(),

                    const SizedBox(height: 8),

                    /// Browse App First
                    _browseAppFirst(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem(String icon, String title, String text) {
    return SizedBox(
      width: 90, // <-- IMPORTANT: gives text a boundary to wrap inside
      child: Column(
        children: [
          Image.asset(icon, height: 50),
          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            text,
            textAlign: TextAlign.center,
            softWrap: true,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthlyPlanCardStyled(SubscriptionPlan plan) {
    final bool isSelected = selectedPlan?.id == plan.id;
    return GestureDetector(
      onTap: () {
        setState(() => selectedPlan = plan);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            painter: QuoteBorderPainter(
              color: isSelected
                  ? const Color(0xFF295BBE)
                  : const Color(0xFF7AA3E5),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFCFE2FF)
                    : const Color(0xFFDFF0FF),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Text("MONTHLY",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text("₹ ${plan.price}/ month",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Billed monthly",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          /// QUOTATION MARKS EXACTLY IN GAPS
          Positioned(
            top: -6,
            left: -4,
            child: Text(
              "“",
              style: TextStyle(
                fontSize: 32,
                color: const Color(0xFF295BBE),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            bottom: -25,
            right: -4,
            child: Text(
              "”",
              style: TextStyle(
                fontSize: 32,
                color: const Color(0xFF295BBE),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _yearlyPlanCardStyled(SubscriptionPlan plan) {
    final bool isSelected = selectedPlan?.id == plan.id;

    return GestureDetector(
      onTap: () {
        setState(() => selectedPlan = plan);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            painter: QuoteBorderPainter(
              color: isSelected
                  ? const Color(0xFF295BBE)
                  : const Color(0xFF7AA3E5),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFCFE2FF)
                    : const Color(0xFFDFF0FF),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
      
                  Text("YEARLY",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      
                  const SizedBox(height: 12),
      
                  Text("₹ ${plan.price}/ month",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      
                  const SizedBox(height: 6),
      
                  Text(
                    "Billed monthly",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
      
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
      
          Positioned(
            top: -6,
            left: -4,
            child: Text(
              "“",
              style: TextStyle(
                fontSize: 32,
                color: const Color(0xFF295BBE),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      
          Positioned(
            bottom: -25,
            right: -4,
            child: Text(
              "”",
              style: TextStyle(
                fontSize: 32,
                color: const Color(0xFF295BBE),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      
          /// TAG
          Positioned(
            top: -15,
            left: 10,
            child: Image.asset(AppVector.tag60off, height: 55),
          ),
        ],
      ),
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
  Widget _startFreeTrialButton({
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE0FFF7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.blue.shade900,
            width: 2,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(
            _buttonText,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
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
    return Column(
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
    );
  }

  Widget _subscriptionOptionCard({
    required String title,
    required String subtitle,
    required String price,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F7FF) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            /// Selection indicator
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue),
              ),
              child: selected
                  ? Center(
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              )
                  : null,
            ),

            const SizedBox(width: 12),

            /// Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            /// Price
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
