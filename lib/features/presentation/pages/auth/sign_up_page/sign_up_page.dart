import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';
import 'package:tinydroplets/core/utils/validators.dart';
import 'package:tinydroplets/features/presentation/pages/auth/otp_page/otp_page.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/model/cms_model.dart';
import 'package:flutter/gestures.dart';

import '../../../../../common/widgets/loader.dart';
import '../../../../../core/constant/app_export.dart';
import '../../../../../core/utils/url_opener.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _confPass = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final borderColor = const Color(0xFF2C68EE);
  final borderRadius = BorderRadius.circular(10);

  bool isFormValid = false;
  bool _showPass = true;
  bool _loading = false;
  bool _isChecked = false;

  CmsModel? cmsModel;

  @override
  void initState() {
    super.initState();
    _getCms();
  }

  void _showPassword() {
    setState(() {
      _showPass = !_showPass;
    });
  }

  @override
  void dispose() {
    super.dispose();

    _email.dispose();
    _confPass.dispose();
    _name.dispose();
    _pass.dispose();
  }

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

  final DioClient dioClient = GetIt.instance<DioClient>();
  String? otp;
  String? id;

  Future<void> _signUp(String name, String email, String mobile) async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await dioClient.sendPostRequest(ApiEndpoints.signupUrl, {
        "name": name,
        "email": email,
        "mobile": mobile ?? '',
        "password": _pass.text,
        "accepted_terms": _isChecked,
      });

      if (response.data['status'] == 1) {
        otp = response.data['data']['otp'].toString();
        id = response.data['data']['id'].toString();

        CommonMethods.showSnackBar(context, 'Otp sent on your email');
        setState(() {
          _loading = false;
        });
        goto(context, OtpPage(otp: otp ?? '0', id: id ?? '0', email: _email.text,));
      } else {
        CommonMethods.showSnackBar(context, response.data['message']);
        setState(() {
          _loading = false;
        });
      }

      CommonMethods.devLog(logName: 'Signup response', message: response);
    } catch (e) {
      CommonMethods.showSnackBar(context, e.toString());
      CommonMethods.devLog(logName: 'Error response', message: e.toString());
      setState(() {
        _loading = false;
      });
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C68EE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔵 TOP BLUE SECTION
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, top: 5, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /// 🔙 Back Button
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    //const SizedBox(height: 5),

                    /// Title
                    Text(
                      "Create\nAccount",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),


            Expanded(
              flex: 7,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight, // 👈 THIS IS THE KEY
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _buildInput(
                                      controller: _name,
                                      hint: "Full Name",
                                      icon: Icons.person_outline,
                                      validator: (v) => Validator.validateName(v ?? ''),
                                    ),
                                    const SizedBox(height: 14),

                                    _buildInput(
                                      controller: _email,
                                      hint: "Email address",
                                      icon: Icons.email_outlined,
                                      validator: (v) => Validator.validateEmail(v ?? ''),
                                    ),
                                    const SizedBox(height: 14),

                                    _buildInput(
                                      controller: _pass,
                                      hint: "Password",
                                      icon: Icons.lock_outline,
                                      obscure: _showPass,
                                      suffix: IconButton(
                                        icon: Icon(
                                          _showPass ? Icons.visibility_off : Icons.visibility,
                                          color: const Color(0xFF2C68EE),
                                        ),
                                        onPressed: () {
                                          setState(() => _showPass = !_showPass);
                                        },
                                      ),
                                      validator: (v) => Validator.validatePassword(v ?? ''),
                                    ),
                                    const SizedBox(height: 14),

                                    _buildInput(
                                      controller: _confPass,
                                      hint: "Confirm password",
                                      icon: Icons.lock_outline,
                                      obscure: _showPass,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return "Confirm password required";
                                        }
                                        if (v != _pass.text) {
                                          return "Passwords do not match";
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _isChecked,
                                          activeColor: const Color(0xFF2C68EE),
                                          onChanged: (val) {
                                            setState(() => _isChecked = val ?? false);
                                          },
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                const TextSpan(text: "I agree to Tinydroplets "),
                                                TextSpan(
                                                  text: "Terms & Conditions",
                                                  style: const TextStyle(
                                                    color: Color(0xFF2C68EE),
                                                    decoration: TextDecoration.underline,
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
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      UrlOpener.launchURL(
                                                        "https://tinydroplets.com/privacy-policy",
                                                      );
                                                    },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    _loading
                                        ? const Loader()
                                        : AppButton(
                                      text: "Sign up",
                                      color: const Color(0xFF2C68EE),
                                      valid: true,
                                      onPressed: () async {
                                        if (!_isChecked) {
                                          CommonMethods.showSnackBar(
                                              context, "Please accept Terms & Conditions");
                                          return;
                                        }

                                        if (_formKey.currentState!.validate()) {
                                          await _signUp(
                                            _name.text,
                                            _email.text,
                                            '',
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// 👶 FLOATING BABY IMAGE
                  Positioned(
                    top: -140,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        AppVector.babyImage7,
                        height: 150,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black87),
        suffixIcon: suffix,
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF2C68EE),
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2C68EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2C68EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2C68EE), width: 2),
        ),
      ),
    );
  }



  /// Shared input decoration same as Login Page
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF2C68EE),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF2C68EE),
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C68EE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C68EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C68EE), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }


  void _showSnack() {
    CommonMethods.showSnackBar(context, 'Not available');
  }
}
