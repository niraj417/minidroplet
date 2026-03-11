import 'package:tinydroplets/core/constant/app_vector.dart';
import 'package:tinydroplets/features/presentation/pages/auth/login_page/login_page.dart';

import '../../../../core/constant/app_export.dart';
import '../dashboard/dashboard.dart';
import 'lets_get_started_page.dart';

class LauncherPage extends StatefulWidget {
  const LauncherPage({super.key});

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => navigateToNextScreen());
  }

  void navigateToNextScreen() {
    final bool isOnboardingViewed = SharedPref.getOnboardingViewed();
    final bool keepLoggedIn = SharedPref.getKeepLoggedIn();
    final loginData = SharedPref.getLoginData();

    if (!isOnboardingViewed) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LetsGetStartedPage()),
        (route) => false,
      );
    } else if (keepLoggedIn && loginData != null && loginData.data?.apiToken != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Dashboard()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(body: Center(child: Image.asset(AppVector.logo, fit: BoxFit.contain,height: 100, width: 100,)));
    // return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
