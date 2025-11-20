import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:tinydroplets/core/constant/app_fonts.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';
import 'package:tinydroplets/features/presentation/pages/auth/sign_up_page/sign_up_page.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/utils/url_opener.dart';
import '../auth/login_page/login_page.dart';
import '../dashboard/dashboard.dart';
import 'new_onboarding_page.dart';
import 'package:flutter/material.dart';

class LetsGetStartedPage extends StatefulWidget {
  const LetsGetStartedPage({super.key});

  @override
  State<LetsGetStartedPage> createState() => _LetsGetStartedPageState();
}

class _LetsGetStartedPageState extends State<LetsGetStartedPage> {
  @override
  void initState() {
    super.initState();
  }

  bool _isOnboardingViewed = false;

  Future<void> navigateToNextScreen() async {
    _isOnboardingViewed = SharedPref.getOnboardingViewed();
    final keepLoggedIn = await SharedPref.getKeepLoggedIn();
    final loginData = SharedPref.getLoginData();

    await Future.delayed(Duration(seconds: 1));

    if (!mounted) return;

    if (_isOnboardingViewed) {
      if (keepLoggedIn && loginData?.data?.apiToken != null) {
        gotoRemoveAll(context, Dashboard());
      } else {
        gotoRemoveAll(context, LoginPage());
        // gotoRemoveAll(context, NewOnboardingPage());
      }
    } else {
      gotoRemoveAll(context, NewOnboardingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF1D62CF)),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 6.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 0.9,
                        fontFamily: AppFonts.bobbyRough,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      'to Tinydroplets',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: AppFonts.bobbyRough,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      'Your one stop solution for baby friendly recipes and joyful parenting',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              Image.asset(
                AppVector.babyImage,
                height: 35.h,
                fit: BoxFit.contain,
              ),

              Padding(
                padding: EdgeInsets.all(8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Text(
                        "Let's Get\nStarted!",
                        style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(width: 5.w),

                    GestureDetector(
                      onTap: () async {
                        final agreed = await DisclaimerBottomSheet.show(context);
                        debugPrint('User agreed: $agreed');
                        if (agreed == true) {
                          navigateToNextScreen();
                        }
                      },
                      child: Image.asset(
                        AppVector.arrow,
                        width: 16.w,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisclaimerBottomSheet {
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const DisclaimerContent();
      },
    );
  }
}

class DisclaimerContent extends StatelessWidget {
  const DisclaimerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            // --- Top Handle & Title ---
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  const SizedBox(
                    width: 40,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Disclaimer",
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
      
            // --- Scrollable Text Section ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Important Notice: Please Read Before You Begin\n\n"
                          "This app is created for educational and informational purposes only. It does not replace medical advice, diagnosis, or treatment from your pediatrician or healthcare provider.\n\n"
                          "• Every baby develops at a different pace.\n"
                          "• Always consult your doctor before starting solids, especially if your baby:\n"
                          "    * Was born prematurely\n"
                          "    * Has allergies or feeding difficulties\n"
                          "    * Has any health conditions or special dietary needs\n\n"
                          "We strive to offer accurate and helpful content, but feeding and safety practices must be personalized based on your child's needs.\n"
                          "Safety is your responsibility. Always supervise your baby during meals and activities. Check for choking hazards, food allergies, and readiness cues.\n\n"
                          "💼 About Product Links & Purchases\n\n"
                          "This app may include:\n"
                          "    • Product suggestions and links (some may be affiliate)\n"
                          "    • Brand collaborations or sponsored content\n"
                          "    • Digital products for purchase (eBooks, printable activity kits, etc.)\n\n"
                          "We only recommend what we trust. Some links may earn us a small commission — at no extra cost to you.\n\n"
                          "📜 By using this app, you agree to: Terms & Condition",
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
      
            // --- Static Footer (Link + Button) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      UrlOpener.launchURL("https://tinydroplets.com/terms-conditions");
                      // TODO: Open full terms link
                    },
                    child: Text(
                      "*Full terms & conditions*",
                      style: TextStyle(
                        color: Color(0xff295BBE),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "By clicking here, you confirm that you have read and agree to the above.",
                      style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14,
                          wordSpacing: 1.8
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primarySwatch.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "I Agree",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}