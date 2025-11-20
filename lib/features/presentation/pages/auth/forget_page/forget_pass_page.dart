import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/features/presentation/pages/auth/otp_page/otp_page.dart';

import '../../../../../common/widgets/loader.dart';
import '../../../../../core/constant/app_export.dart';
import '../../../../../core/constant/app_vector.dart';
import '../../../../../core/utils/validators.dart';
import 'bloc/forget_password_cubit.dart';
import 'bloc/forget_password_state.dart';

/*class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({super.key});

  @override
  State<ForgetPassPage> createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrMobile = TextEditingController();

  final borderColor = const Color(0xFF2C68EE);
  final borderRadius = BorderRadius.circular(10);
  bool _loading = false;

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
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF2C68EE),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _emailOrMobile,
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(color: borderColor),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: borderRadius,
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: borderRadius,
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: borderRadius,
                                borderSide: BorderSide(
                                  color: borderColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                            validator: (value) {
                              return Validator.validateMobileOrEmail(value!);
                            },
                          ),

                          const SizedBox(height: 40),
                          _loading
                              ? Loader()
                              : AppButton(
                                color: const Color(0xFF2C68EE),
                                text: 'Forget',
                                valid:
                                    _formKey.currentState?.validate() ?? false,
                                onPressed: () async {
                                  goto(context, OtpPage(otp: 'otp', id: 'id'));
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                // left: 30,
                // right: 30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackButton(
                      color: Colors.white,
                      onPressed: () => backTo(context),
                    ),
                    SizedBox(width: 20),
                    const Text(
                      'Forgot your\npassword?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    -MediaQuery.of(context).size.height * -0.03,
                  ),
                  child: Center(
                    child: Image.asset(
                      AppVector.babyImage7,
                      height: MediaQuery.of(context).size.height * 0.32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({super.key});

  @override
  State<ForgetPassPage> createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrMobile = TextEditingController();

  final borderColor = const Color(0xFF2C68EE);
  final borderRadius = BorderRadius.circular(10);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordCubit(),
      child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
        listener: (context, state) {
          if (state is ForgetPasswordLoading) {
            Loader();
          } else {
            if (state is ForgetPasswordSuccess) {
              goto(context, OtpPage(otp: state.otp, id: state.id, email: 'email',));
            } else if (state is ForgetPasswordError) {
              CommonMethods.showSnackBar(context, state.message);
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFF2C68EE),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextFormField(
                                  controller: _emailOrMobile,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email',
                                    hintStyle: TextStyle(color: borderColor),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: borderRadius,
                                      borderSide: BorderSide(
                                        color: borderColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: borderRadius,
                                      borderSide: BorderSide(
                                        color: borderColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: borderRadius,
                                      borderSide: BorderSide(
                                        color: borderColor,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    return Validator.validateMobileOrEmail(
                                      value!,
                                    );
                                  },
                                ),
                                const SizedBox(height: 40),
                                AppButton(
                                  color: const Color(0xFF2C68EE),
                                  text: 'Forget',
                                  valid:
                                      _formKey.currentState?.validate() ??
                                      false,
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      context
                                          .read<ForgetPasswordCubit>()
                                          .forgetPassword(
                                            _emailOrMobile.text.trim(),
                                          );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BackButton(
                            color: Colors.white,
                            onPressed: () => backTo(context),
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            'Forgot your\npassword?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.45,
                      left: 0,
                      right: 0,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          -MediaQuery.of(context).size.height * -0.03,
                        ),
                        child: Center(
                          child: Image.asset(
                            AppVector.babyImage7,
                            height: MediaQuery.of(context).size.height * 0.32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
