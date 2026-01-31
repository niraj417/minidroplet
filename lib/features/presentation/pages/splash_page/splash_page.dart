import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/utils/shared_pref.dart';
import 'package:tinydroplets/features/presentation/pages/auth/login_page/login_page.dart';
import 'package:tinydroplets/features/presentation/pages/dashboard/dashboard.dart';
import 'package:tinydroplets/features/presentation/pages/splash_page/new_onboarding_page.dart';
import 'package:tinydroplets/features/presentation/pages/splash_page/onboarding_page.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/constant/app_vector.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isOnboardingViewed = false;

  /*
  Future<void> checkLoginStatus() async {
    final keepLoggedIn = await SharedPref.getKeepLoggedIn();
    final loginData = SharedPref.getLoginData();

    if (keepLoggedIn && loginData!.data!.apiToken != null) {
      gotoRemoveAll(context, Dashboard());
    } else {
      gotoRemoveAll(context, LoginPage());
    }
  }

  @override
  void initState() {
    super.initState();
    checkOnboardingStatus();
  }

  Future<void> checkOnboardingStatus() async {
    _isOnboardingViewed = SharedPref.getOnboardingViewed();
    gotoToNext();
  }

  Future<void> gotoToNext() async {
    Future.delayed(
      Duration(seconds: 4),
      () {
        if (!mounted) return;

        if (_isOnboardingViewed) {
          gotoReplacement(context, LoginPage());
        } else {
          gotoReplacement(context, OnboardingScreen());
        }
      },
    );
  }*/

  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    _isOnboardingViewed = SharedPref.getOnboardingViewed();
    final keepLoggedIn = SharedPref.getKeepLoggedIn();
    final loginData = SharedPref.getLoginData();

    await Future.delayed(Duration(seconds: 1));

    if (!mounted) return;

    if (_isOnboardingViewed) {
      if (keepLoggedIn && loginData?.data?.apiToken != null) {
        gotoRemoveAll(context, Dashboard());
      } else {
        gotoRemoveAll(context, LoginPage());
        // gotoRemoveAll(context, OnboardingScreen());
      }
    } else {
      gotoRemoveAll(context, NewOnboardingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppVector.logo,
                    fit: BoxFit.cover,
                    height: 120,
                    width: 270,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Access a vast library of eBooks to read at your convenience.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 16.0,
                ), // Adjust padding if needed
                child: Loader(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
