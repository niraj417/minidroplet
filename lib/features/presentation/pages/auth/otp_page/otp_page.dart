import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tinydroplets/common/widgets/app_button.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/auth/create_password_page/create_password_page.dart';
import 'package:tinydroplets/features/presentation/pages/auth/login_page/login_page.dart';
import 'package:tinydroplets/features/presentation/pages/dashboard/dashboard.dart';
import '../../../../../core/constant/app_export.dart';
import '../../../../../core/constant/app_vector.dart';
import '../../../../../core/network/api_controller.dart';
import '../../../../../core/network/api_endpoints.dart';

class OtpPage extends StatefulWidget {
  final String otp;
  final String email;
  final String id;
  final bool fromForgetPass;

  const OtpPage({
    super.key,
    required this.otp,
    required this.id,
    required this.email,
    this.fromForgetPass = false, // Default value, not required
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _pin = TextEditingController();
  late Timer _timer;
  int _remainingSeconds = 60;
  bool _isTimerActive = true;
  bool _loading = false;

  late String _otp;
  late String _id;

  final DioClient dioClient = GetIt.instance<DioClient>();

  @override
  void initState() {
    super.initState();
    if(widget.otp == '0'){
      _resendOtp(widget.id);
    }
    _otp = widget.otp;
    _id = widget.id;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        setState(() => _isTimerActive = false);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    //_pin.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendOtp(String id) async {
    try {
      final response = await dioClient.sendPostRequest(ApiEndpoints.resendOtp, {"id": id});
      CommonMethods.devLog(logName: 'Resend res', message: response);
      if (response.data['status'] == 1) {
        _otp = response.data['data'].toString();
        setState(() {
          _remainingSeconds = 60;
          _isTimerActive = true;
        });
        startTimer();
      } else {
        CommonMethods.showSnackBar(context, response.data['message']);
      }
    } catch (e) {
      CommonMethods.showSnackBar(context, e.toString());
    }
  }

  Future<void> _verifyOtp(String id, String otp) async {
    setState(() => _loading = true);
    try {
      final response = await dioClient.sendPostRequest(ApiEndpoints.verifyOtp, {"id": id, "otp": otp});
      CommonMethods.devLog(logName: 'Verify res', message: response);

      if (response.data['status'] == 1) {
        final serverOtp = response.data['data']['otp'].toString();
        if (serverOtp == otp) {
          CommonMethods.showSnackBar(context, "OTP Verified Successfully!");
          if(widget.fromForgetPass){
            gotoReplacement(context, CreatePasswordPage(id: widget.id));
          } else {
            gotoReplacement(context, LoginPage());
          }
        } else {
          CommonMethods.showSnackBar(context, "Invalid OTP. Please try again.");
        }
      } else {
        CommonMethods.showSnackBar(context, response.data['message'] ?? "Verification failed.");
      }
    } catch (e) {
      CommonMethods.showSnackBar(context, "An error occurred: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFE9F1FF),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 📨 Mail Icon
                Image.asset(
                  "assets/images/email_img.png", // replace with your mail image path
                  height: 130,
                  width: 130,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),

                // 🧾 Title
                Text(
                  'Check your email',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // 📝 Subtext
                Text(
                  'We sent a 4 digit code to',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  '${widget.email}', // replace dynamically later
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // 🔢 OTP Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: PinCodeTextField(
                    appContext: context,
                    controller: _pin,
                    length: 4,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    enableActiveFill: true,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 55,
                      fieldWidth: 45,
                      inactiveColor: Colors.grey.shade300,
                      activeColor: Colors.blueAccent,
                      selectedColor: Colors.blueAccent,
                      inactiveFillColor: Colors.grey.shade100,
                      selectedFillColor: Colors.white,
                      activeFillColor: Colors.white,
                      fieldOuterPadding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 30),

                // ✅ Verify Button
                _loading
                    ? const Loader()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _pin.text.isNotEmpty
                        ? () async {
                      await _verifyOtp(_id, _pin.text);
                    }
                        : null,
                    child: Text(
                      'Verify',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔁 Resend Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the email? ",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: !_isTimerActive ? () => _resendOtp(_id) : null,
                      child: Text(
                        _isTimerActive
                            ? 'Resend(${_remainingSeconds})'
                            : 'Resend',
                        style: GoogleFonts.poppins(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // optional debug text
                // Text(
                //   'Your OTP is: $_otp',
                //   style: TextStyle(
                //     color: Colors.grey.shade400,
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}