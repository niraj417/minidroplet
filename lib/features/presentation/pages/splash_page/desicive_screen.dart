import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';
import 'package:tinydroplets/features/presentation/pages/auth/login_page/login_page.dart';
import 'package:tinydroplets/features/presentation/pages/auth/sign_up_page/sign_up_page.dart';
import 'package:flutter/gestures.dart';

import '../../../../common/widgets/loader.dart';
import '../../../../core/utils/shared_pref_key.dart';
import '../../../../core/utils/url_opener.dart';
import '../auth/login_page/model/login_data_model.dart';
import '../dashboard/dashboard.dart';
import '../subscription/subscription_screen.dart';

class DesiciveScreen extends StatefulWidget { const DesiciveScreen({super.key}); @override State<DesiciveScreen> createState() => _DesiciveScreenState(); }

class _DesiciveScreenState extends State<DesiciveScreen> {
  bool _agreeTerms = false;
  bool _isChecked = true;
  bool _loading2 = false;
  bool _loading3 = false;
  bool _loading4 = false;
  final DioClient dioClient = GetIt.instance<DioClient>();
  final String? fcmToken = SharedPref.getString('fcmToken');

  Future<void> _thirdPartyAuth(String name, String email, String password,
      String? deviceToken, String deviceName) async {
    try {
      final response =
      await dioClient.sendPostRequest(ApiEndpoints.thirdPartyAuth, {
        "name": name,
        "email": email,
        "password": password,
        "device_token": deviceToken,
        "device_name": deviceName,
      });

      CommonMethods.devLog(logName: 'Login res', message: response);

      if (response.data['status'] == 1) {
        //CommonMethods.showSnackBar(context, response.data['message']);
        final loginData = LoginDataModel.fromJson(response.data);
        final subscription = loginData.data?.subscription;

        final bool hasPremiumAccess =
            subscription != null &&
                (
                    subscription.isTrial == 1 ||
                        (
                            subscription.isActive == 1 &&
                                subscription.expiryDate != null &&
                                subscription.expiryDate!.isAfter(DateTime.now())
                        )
                );
        await SharedPref.saveLoginData(loginData);
        await SharedPref.setKeepLoggedIn(_isChecked);
        // ✅ persist locally for instant UI
        await SharedPref.setBool('isSubscribed', loginData.data!.subscription == null ? false : loginData.data!.subscription?.isActive == 0 ? false : true );
        await SharedPref.setBool('isTrial', loginData.data!.subscription?.isTrial == 0 ? false : true);
        await SharedPref.setBool('trialAvailed', loginData.data?.trialAvailed != null ? loginData.data?.trialAvailed == 0 ? false : true : false);
        await SharedPref.setString(
          'trialExpiry',
          loginData.data!.subscription?.expiryDate?.toIso8601String() ?? '',
        );
        await SharedPref.setBool(SharedPrefKeys.hasPremiumAccess, hasPremiumAccess);
        debugPrint("isSubscribed: ${loginData.data!.subscription?.isActive}");
        debugPrint("isThisTrialRunning: ${loginData.data!.subscription?.isTrial}");
        debugPrint("isTrialAvailed: ${loginData.data?.trialAvailed}");
        debugPrint("Trial Expiry: ${loginData.data!.subscription?.expiryDate?.toIso8601String() ?? ' '}");

        if(loginData.data!.subscription != null && (loginData.data!.subscription!.isActive == 1)) {
          gotoRemoveAll(context, Dashboard());
        } else {
          gotoRemoveAll(context, SubscriptionPage(fromLogin: true,));
        }
        gotoRemoveAll(context, Dashboard());
      } else {
        setState(() => _loading3 = false);
        setState(() => _loading2 = false);
        setState(() => _loading4 = false);
        CommonMethods.showSnackBar(context, response.data['message']);
      }
    } catch (e) {
      setState(() => _loading3 = false);
      setState(() => _loading2 = false);
      setState(() => _loading4 = false);
      CommonMethods.showSnackBar(context, e.toString());
      CommonMethods.devLog(logName: 'Error response', message: e.toString());
    } finally {
      setState(() => _loading3 = false);
      setState(() => _loading2 = false);
      setState(() => _loading4 = false);
    }
  }

  @override
  void initState() {
    SharedPref.setOnboardingViewed(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, // Color for this specific screen
        //systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.white,
        statusBarColor: const Color(0xFF2C68EE),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF2C68EE),
        body: SafeArea(
          child: Column(
            children: [
              /// TOP SECTION
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lets\nget started",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            ),
                            child: Text(
                              "Sign in",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFFB300),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// WHITE SECTION WITH FLOATING BABY IMAGE
              Expanded(
                flex: 7,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      //padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight, // 👈 THIS IS THE KEY
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                                child: Column(
                                  children: [
                                    //const SizedBox(height: 80), // space for floating baby
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _agreeTerms,
                                          activeColor: const Color(0xFF2C68EE),
                                          onChanged: (val) {
                                            setState(() {
                                              _agreeTerms = val ?? false;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                const TextSpan(text: "I agree to Tinydroplets "),
                                                TextSpan(
                                                  text: "Terms & Conditions",
                                                  style: const TextStyle(
                                                    color: Color(0xFF2C68EE),
                                                    decoration: TextDecoration.underline,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      UrlOpener.launchURL(
                                                        "https://tinydroplets.com/terms-conditions",
                                                      );
                                                    },
                                                ),
                                                const TextSpan(text: " and acknowledge the "),
                                                TextSpan(
                                                  text: "Privacy Policy",
                                                  style: const TextStyle(
                                                    color: Color(0xFF2C68EE),
                                                    decoration: TextDecoration.underline,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      UrlOpener.launchURL(
                                                        "https://tinydroplets.com/privacy-policy-2",
                                                      );
                                                    },
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2C68EE),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        onPressed: _agreeTerms
                                            ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                                          );
                                        }
                                            : null,
                                        child: Text(
                                          "Create account",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    _loading2
                                        ? const Loader()
                                        : _socialButton(
                                      icon: 'assets/images/google.png',
                                      text: 'Continue with Google',
                                      onPressed: _agreeTerms ? _handleGoogleSignIn : null,
                                    ),
                                    const SizedBox(height: 10),

                                    if(Platform.isIOS)
                                      _loading3
                                          ? const Loader()
                                          : _socialButton(
                                        icon: 'assets/images/apple.png',
                                        text: 'Continue with Apple',
                                        onPressed: _agreeTerms ? _handleAppleSignIn : null,
                                      ),

                                    const SizedBox(height: 12),

                                    if(Platform.isIOS)
                                      Text(
                                        "Explore without Login",
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),

                                    const SizedBox(height: 6),

                                    if(Platform.isIOS)
                                      OutlinedButton(
                                        onPressed: () async {
                                          setState(() => _loading4 = true);
                                          const guestName = "Guest User";
                                          const guestEmail = "guest@tinydroplets.com";
                                          const guestPassword = "guest123";
                                          const deviceName = "ios";

                                          await _thirdPartyAuth(
                                            guestName,
                                            guestEmail,
                                            guestPassword,
                                            "guest_token_123", // you can pass null if not needed
                                            deviceName,
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFF2C68EE)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: !_loading4 ? const Text("Continue as Guest User") : Loader(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ),

                    /// ✅ FLOATING BABY IMAGE
                    Positioned(
                      top: -145,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          AppVector.babyImage7,
                          height: 160,
                        ),
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
  Widget _socialButton({
    required String icon,
    required String text,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Image.asset(icon, height: 20),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// 🟢 Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _loading2 = true);
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut(); // Force account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final name = googleUser.displayName ?? 'Google User';
      final email = googleUser.email;
      final id = googleUser.id;

      if (email.isNotEmpty && id.isNotEmpty) {
        if (Platform.isAndroid) {
          _thirdPartyAuth(name, email, id, fcmToken, 'Android');
        } else {
          _thirdPartyAuth(name, email, id, fcmToken, 'ios');
        }
      } else {
        setState(() => _loading2 = false);
      }
    } catch (e) {
      setState(() => _loading2 = false);
      CommonMethods.showSnackBar(context, 'Google Sign-In Error: $e');
    }
  }

  /// 🍎 Handle Apple Sign-In
  Future<void> _handleAppleSignIn() async {
    setState(() => _loading2 = true);
    try {
      final credential = await apple.SignInWithApple.getAppleIDCredential(
        scopes: [
          apple.AppleIDAuthorizationScopes.email,
          apple.AppleIDAuthorizationScopes.fullName,
        ],
      );

      final name =
      '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      final email = credential.email ?? 'apple_user@domain.com';
      final password = credential.userIdentifier ?? '';

      if (Platform.isAndroid) {
        _thirdPartyAuth(name, email, password, fcmToken, 'Android');
      } else {
        _thirdPartyAuth(name, email, password, fcmToken, 'ios');
      }
    } catch (e) {
      setState(() => _loading2 = false);
      CommonMethods.showSnackBar(context, 'Apple Sign-In Error: $e');
    }
  }
}

