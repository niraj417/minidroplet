import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/auth/login_page/login_page.dart';

import '../../../../../common/widgets/custom_text_field.dart';
import '../../../../../core/constant/app_export.dart';
import '../../../../../core/constant/app_vector.dart';
import '../../../../../core/network/api_controller.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/utils/validators.dart';

class CreatePasswordPage extends StatefulWidget {
  final String id;
  const CreatePasswordPage({super.key, required this.id});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final TextEditingController _pass1 = TextEditingController();
  final TextEditingController _pass2 = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isFormValid = false;
  bool _showPass = true;

  void _showPassword() {
    setState(() {
      _showPass = !_showPass;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _pass1.dispose();
    _pass2.dispose();
  }

  final DioClient dioClient = GetIt.instance<DioClient>();

  bool _loading = false;

  Future<void> _createPassword(String id, password, confirmPassword) async {
    setState(() {
      _loading = true;
    });
    try {
      final response =
          await dioClient.sendPostRequest(ApiEndpoints.confirmPassword, {
        "id": id,
        "password": password,
        "password_confirmation": confirmPassword,
      });
      CommonMethods.devLog(logName: 'Confirm Password res', message: response);

      if (response.data['status'] == 1) {
        setState(() {
          _loading = false;
        });
        CommonMethods.showSnackBar(context, response.data['message']);

        gotoRemoveAll(context, LoginPage());

      } else {
        CommonMethods.showSnackBar(context, response.data['message']);
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      CommonMethods.showSnackBar(context, e.toString());
      CommonMethods.devLog(logName: 'Error response', message: e.toString());
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
            ),
            Center(
              child: Image.asset(
                AppVector.babyImage7,
                height: MediaQuery.of(context).size.height * 0.32,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Create Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Password',
                    obscureText: _showPass,
                    hintText: 'Enter password',
                    keyboardType: TextInputType.visiblePassword,
                    controller: _pass1,
                    onChanged: (value) {
                      setState(() {
                        isFormValid =
                            _formKey.currentState?.validate() ?? false;
                      });
                    },
                    validator: (value) {
                      return Validator.validateSimplePassword(value ?? '');
                    },
                    prefixIcon: Icon(CupertinoIcons.lock),
                    suffixIcon: InkWell(
                        onTap: () => _showPassword(),
                        child: Icon(!_showPass
                            ? Icons.visibility
                            : Icons.visibility_off)),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  CustomTextField(
                    label: 'Confirm Password',
                    obscureText: _showPass,
                    hintText: 'Enter password',
                    keyboardType: TextInputType.visiblePassword,
                    controller: _pass2,
                    onChanged: (value) {
                      setState(() {
                        isFormValid =
                            _formKey.currentState?.validate() ?? false;
                      });
                    },
                    validator: (value) {
                      return Validator.validateSimplePassword(value ?? '');
                    },
                    prefixIcon: Icon(CupertinoIcons.lock),
                    suffixIcon: InkWell(
                        onTap: () => _showPassword(),
                        child: Icon(!_showPass
                            ? Icons.visibility
                            : Icons.visibility_off)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            _loading
                ? Loader()
                : AppButton(
                    useCupertino: true,
                    valid: isFormValid && _pass1.text == _pass2.text,
                    text: 'Create',
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _createPassword(
                            widget.id, _pass1.text, _pass2.text);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
