import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple;
import 'package:sizer/sizer.dart';
import 'package:tinydroplets/common/widgets/app_button.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';
import 'package:tinydroplets/core/utils/shared_pref.dart';
import 'package:tinydroplets/features/presentation/pages/auth/otp_page/otp_page.dart';
import 'package:tinydroplets/features/presentation/pages/auth/sign_up_page/sign_up_page.dart';
import 'package:tinydroplets/features/presentation/pages/dashboard/dashboard.dart';
import '../../../../../core/constant/app_export.dart';
import '../../../../../core/utils/validators.dart';
import 'model/login_data_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrMobile = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isChecked = true;
  bool _showPass = true;
  bool _loading = false;
  bool _loading2 = false;
  bool _loading3 = false;

  final DioClient dioClient = GetIt.instance<DioClient>();
  final String? fcmToken = SharedPref.getString('fcmToken');

  @override
  void dispose() {
    _emailOrMobile.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _showPassword() => setState(() => _showPass = !_showPass);

  Future<void> _login(
      String emailOrMobile, String password, String? deviceToken, String deviceName) async {
    setState(() => _loading = true);
    try {
      final response = await dioClient.sendPostRequest(ApiEndpoints.loginUrl, {
        "mobile_email": emailOrMobile,
        "password": password,
        "device_token": deviceToken,
        "device_name": deviceName,
      });

      CommonMethods.devLog(logName: 'Login res', message: response);

      if (response.data['status'] == 1) {
        // Check for unverified user
        if (response.data['message'].toLowerCase().contains('unverified') &&
            response.data['data'] != null) {
          CommonMethods.showSnackBar(context, response.data['message']);

          // Navigate to OTP verification page with user data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(
                id: response.data['data']['id'].toString(),
                email: response.data['data']['email'],
                otp: '0', // Flag to indicate this is from login flow
              ),
            ),
          );
        } else {

          CommonMethods.showSnackBar(context, response.data['message']);
        }
        //CommonMethods.showSnackBar(context, response.data['message']);
        final loginData = LoginDataModel.fromJson(response.data);
        await SharedPref.saveLoginData(loginData);
        await SharedPref.setKeepLoggedIn(_isChecked);
        gotoRemoveAll(context, Dashboard());
      }
    } catch (e) {
      CommonMethods.showSnackBar(context, e.toString());
      CommonMethods.devLog(logName: 'Error response', message: e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

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
        await SharedPref.saveLoginData(loginData);
        await SharedPref.setKeepLoggedIn(_isChecked);
        gotoRemoveAll(context, Dashboard());
      } else {
        setState(() => _loading3 = false);
        setState(() => _loading2 = false);
        CommonMethods.showSnackBar(context, response.data['message']);
      }
    } catch (e) {
      setState(() => _loading3 = false);
      setState(() => _loading2 = false);
      CommonMethods.showSnackBar(context, e.toString());
      CommonMethods.devLog(logName: 'Error response', message: e.toString());
    } finally {
      setState(() => _loading3 = false);
      setState(() => _loading2 = false);
    }
  }

  /// 🔹 Reusable Social Button
  Widget _socialButton({
    required String icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250,
      height: 40,
      child: OutlinedButton.icon(
        icon: Image.asset(icon, height: 22),
        label: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(AppColor.primaryColor), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: const Color(0xFF2C68EE),
          child: Column(
            children: [
              // 🔹 Top Blue Header
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h, left: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi Welcome\nBack!',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () => goto(context, const SignUpPage()),
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.poppins(
                                decoration: TextDecoration.underline,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFFFFB300),
                                decorationColor: const Color(0xFFFFB300),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      
              // 🔹 Bottom White Section
              Expanded(
                flex: 7,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // White Container
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ------------------ Form Starts ------------------
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailOrMobile,
                                      decoration: InputDecoration(
                                        labelText: 'Email or Mobile Number',
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF2C68EE),
                                          fontSize: 14,
                                        ),
                                        floatingLabelStyle: const TextStyle(
                                          color: Color(0xFF2C68EE),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 18),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF2C68EE)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF2C68EE)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF2C68EE), width: 2),
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) =>
                                          Validator.validateMobileOrEmail(
                                              value ?? ''),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _pass,
                                      obscureText: _showPass,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: const TextStyle(
                                          color: Color(0xFF2C68EE),
                                          fontSize: 14,
                                        ),
                                        floatingLabelStyle: const TextStyle(
                                          color: Color(0xFF2C68EE),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        suffixIcon: InkWell(
                                          onTap: _showPassword,
                                          child: Icon(
                                            _showPass
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF2C68EE),
                                          ),
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 18),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF2C68EE)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF2C68EE)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF2C68EE), width: 2),
                                        ),
                                      ),
                                      validator: (value) =>
                                          Validator.validateSimplePassword(
                                              value ?? ''),
                                    ),
                                    const SizedBox(height: 8),
      
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Forgot password?',
                                          style: GoogleFonts.poppins(
                                            decoration:
                                            TextDecoration.underline,
                                            color: const Color(0xFF2C68EE),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
      
                                    // 🔹 Continue Button
                                    _loading
                                        ? const Loader()
                                        : AppButton(
                                      color: const Color(0xFF2C68EE),
                                      text: 'Continue',
                                      textStyle: GoogleFonts.poppins(
                                        color: Color(0xFFffA314),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                      valid: true,
                                      onPressed: () async {
                                        if (_formKey.currentState!
                                            .validate()) {
                                          if (Platform.isAndroid) {
                                            _login(
                                                _emailOrMobile.text,
                                                _pass.text,
                                                fcmToken,
                                                'Android');
                                          } else {
                                            _login(
                                                _emailOrMobile.text,
                                                _pass.text,
                                                fcmToken,
                                                'ios');
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // ------------------ Form Ends ------------------
                              const SizedBox(height: 20),
      
                              // 🔹 Social Login Buttons (OUTSIDE FORM)
                              _loading2
                                  ? const Loader()
                                  : _socialButton(
                                icon: 'assets/images/google.png',
                                text: 'Continue with Google',
                                onPressed: _handleGoogleSignIn,
                              ),
                              const SizedBox(height: 10),
                              _loading2
                                  ? const Loader()
                                  : _socialButton(
                                icon: 'assets/images/apple.png',
                                text: 'Continue with Apple',
                                onPressed: _handleAppleSignIn,
                              ),
                              const SizedBox(height: 10),
      
                              Text(
                                'Explore without Login',
                                style: GoogleFonts.poppins(
                                  color: AppColor.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 6),
      
                              _loading3
                                  ? const Loader()
                                  :OutlinedButton(
                                onPressed: () async {
                                  setState(() => _loading3 = true);
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
                                  side: const BorderSide(
                                      color: Color(0xff295BBE)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 24),
                                ),
                                child: Text(
                                  'Continue as Guest User',
                                  style: GoogleFonts.poppins(
                                    color: Color(0xff295BBE),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      height: double.infinity,
                    ),
      
                    // 🔹 Floating Baby Image
                    Positioned(
                      top: -140,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          AppVector.babyImage7,
                          height: 150,
                          width: 150,
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
