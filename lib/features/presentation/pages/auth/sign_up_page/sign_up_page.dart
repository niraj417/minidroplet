import 'package:get_it/get_it.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';
import 'package:tinydroplets/core/utils/validators.dart';
import 'package:tinydroplets/features/presentation/pages/auth/otp_page/otp_page.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/model/cms_model.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/privacy_policy_screen.dart';

import '../../../../../core/constant/app_export.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
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
    _mobile.dispose();
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
        "mobile": mobile,
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
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [

              // 🔵 Blue Header Section
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.45,
                color: const Color(0xFF2C68EE),
                padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hi Welcome!\nCreate your account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Already Registered?',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () => backTo(context),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFFFB300),
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

              // ⚪ Bottom Form Section
              Positioned(
                top: MediaQuery.of(context).size.height * 0.42,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 30, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 🔹 NAME
                        TextFormField(
                          controller: _name,
                          decoration: _inputDecoration('Full Name'),
                          validator: (value) =>
                              Validator.validateName(value ?? ''),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 16),

                        // 🔹 EMAIL
                        TextFormField(
                          controller: _email,
                          decoration: _inputDecoration('Email'),
                          validator: (value) =>
                              Validator.validateEmail(value ?? ''),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 16),

                        // 🔹 Terms & Conditions Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: _isChecked,
                                side: const BorderSide(
                                    color: Color(0xFF2C68EE), width: 1.5),
                                activeColor: Colors.white,
                                checkColor: const Color(0xFF2C68EE),
                                onChanged: (v) {
                                  setState(() => _isChecked = v ?? false);
                                  _validateForm();
                                },
                              ),
                            ),

                            Expanded(
                              child: GestureDetector(
                                onTap: cmsModel == null
                                    ? _showSnack
                                    : () => goto(
                                  context,
                                  CmsScreen(
                                    title: cmsModel!
                                        .data!.termsConditions!.title!,
                                    description: cmsModel!.data!
                                        .termsConditions!.description!,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text(
                                    "I agree to the Terms & Conditions",
                                    style: TextStyle(
                                      color: Color(0xFF2C68EE),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 🔹 Sign Up Button
                        _loading
                            ? const CircularProgressIndicator(
                          color: Color(0xFF2C68EE),
                        )
                            : AppButton(
                          color: const Color(0xFF2C68EE),
                          text: 'Sign Up',
                          valid: isFormValid && _isChecked,
                          onPressed: (isFormValid && _isChecked)
                              ? () => _signUp(
                            _name.text,
                            _email.text,
                            _mobile.text, // <-- YOU ALREADY HAD THIS IN LOGIC, NOT REMOVING
                          )
                              : null,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // 👶 Floating Baby Image (correct placement)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.23,
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
