import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_bloc/profile_cubit.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_bloc/profile_state.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_completion/profile_completion_cubit.dart';

import '../../../../common/widgets/custom_text_field.dart';
import '../../../../core/constant/app_export.dart';
import '../../../../core/utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _emailOrMobile = TextEditingController();
  final _mobile = TextEditingController();
  final _address = TextEditingController();
  final _aboutUs = TextEditingController();
  final _key = GlobalKey<FormState>();

  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _babyAgeController = TextEditingController();

  String _parentGender = 'Mother';
  String _babyStatus = 'Expecting a baby';

  // 1. Parents gender select
  // 2. Parents name
  // 3. Baby born // 1. Expecting a baby 2. Baby is born
  // if baby is born then select age in text field enter baby age in month

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    _initializeControllers(cubit.state);
  }

  void _initializeControllers(ProfileState state) {
    _name.text = state.name;
    _emailOrMobile.text = state.email;
    _mobile.text = state.mobile;
    _address.text = state.address;
    _aboutUs.text = state.aboutUs;
    _parentGender = state.parentsGender ?? 'Mother';
    _parentNameController.text = state.parentName ?? '';
    _babyStatus =
        state.babyBorned == true ? 'Baby is born' : 'Expecting a baby';
    _babyAgeController.text = state.babyAge?.toString() ?? '';
    context.read<ProfileCompletionCubit>().getProfileCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.error != null) {
            CommonMethods.showSnackBar(context, state.error!);
            context.read<ProfileCubit>().clearSuccessMessage();
          }

          // Handle success messages
          if (state.successMessage != null) {
            CommonMethods.showSnackBar(context, state.successMessage!);
            context.read<ProfileCubit>().clearSuccessMessage();
          }
          _initializeControllers(state);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileImage(),
                const SizedBox(height: 40),
                _buildFormFields(),
                const SizedBox(height: 40),
                _buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Center(
          child: Stack(
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        state.temporaryImage != null
                            ? FileImage(File(state.temporaryImage!.path))
                            : NetworkImage(state.image) as ImageProvider,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: -6,
                child: Transform.rotate(
                  angle: 44.4,
                  child: IconButton(
                    onPressed: () => context.read<ProfileCubit>().pickImage(),
                    icon: const Icon(CupertinoIcons.pencil_outline),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        const SizedBox(height: 40),
        CustomTextField(
          label: 'Full name',
          hintText: 'Enter your name',
          keyboardType: TextInputType.name,
          controller: _name,
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) {
            return Validator.validateName(value!);
          },
          prefixIcon: Icon(CupertinoIcons.person),
        ),
        const SizedBox(height: 15),
        CustomTextField(
          readOnly: true,
          label: 'Email or Mobile Number',
          hintText: 'Enter your email or mobile number',
          keyboardType: TextInputType.emailAddress,
          controller: _emailOrMobile,
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) {
            return Validator.validateMobileOrEmail(value!);
          },
          prefixIcon: Icon(CupertinoIcons.mail),
        ),
        const SizedBox(height: 15),
        CustomTextField(
          readOnly: true,
          label: 'Mobile',
          hintText: 'Enter your mobile number',
          keyboardType: TextInputType.number,
          controller: _mobile,
          onChanged: (value) {
            setState(() {});
          },
          // validator: (value) {
          //   return Validator.validateMobileNumber(value!);
          // },
          prefixIcon: Icon(CupertinoIcons.phone),
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: 'Address',
          hintText: 'Enter your address',
          keyboardType: TextInputType.streetAddress,
          controller: _address,
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) {
            return Validator.validateAddress(value!);
          },
          prefixIcon: Icon(CupertinoIcons.location),
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: 'About Us',
          hintText: 'Enter details about yourself',
          keyboardType: TextInputType.text,
          controller: _aboutUs,
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) {
            return Validator.validateAboutUs(value!);
          },
          prefixIcon: Icon(CupertinoIcons.info),
        ),

        /// Extra features
        Column(
          children: [
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Parent Gender',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Mother',
                  groupValue: _parentGender,
                  onChanged: (value) {
                    setState(() {
                      _parentGender = value!;
                    });
                  },
                ),
                const Text('Mother'),
                Radio<String>(
                  value: 'Father',
                  groupValue: _parentGender,
                  onChanged: (value) {
                    setState(() {
                      _parentGender = value!;
                    });
                  },
                ),
                const Text('Father'),
              ],
            ),
            const SizedBox(height: 15),

            // Parent Name Text Field
            CustomTextField(
              label: 'Parent Name',
              hintText: 'Enter parent name',
              controller: _parentNameController,
              onChanged: (value) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter parent name';
                }
                return null;
              },
              prefixIcon: Icon(CupertinoIcons.person),
            ),
            const SizedBox(height: 15),

            // Baby Born Status Radio Buttons
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Baby Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Expecting a baby',
                  groupValue: _babyStatus,
                  onChanged: (value) {
                    setState(() {
                      _babyStatus = value!;
                    });
                  },
                ),
                const Text('Expecting a baby'),
                Radio<String>(
                  value: 'Baby is born',
                  groupValue: _babyStatus,
                  onChanged: (value) {
                    setState(() {
                      _babyStatus = value!;
                    });
                  },
                ),
                const Text('Baby is born'),
              ],
            ),
            const SizedBox(height: 15),

            if (_babyStatus == 'Baby is born') ...[
              CustomTextField(
                label: 'Baby Age (in months)',
                hintText: 'Enter baby age in months',
                keyboardType: TextInputType.number,
                controller: _babyAgeController,
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter baby age';
                  }
                  return null;
                },
                prefixIcon: Icon(CupertinoIcons.calendar),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return state.isLoading
            ? const Loader()
            // : AppButton(
            //   text: 'Update',
            //   onPressed: () {
            //     if (_key.currentState!.validate()) {
            //       context.read<ProfileCubit>().updateProfile(
            //         name: _name.text,
            //         email: _emailOrMobile.text,
            //         mobile: _mobile.text,
            //         address: _address.text,
            //         aboutUs: _aboutUs.text,
            //       );
            //     }
            //   },
            // );
            : AppButton(
              text: 'Update',
              onPressed: () {
                if (_key.currentState!.validate()) {
                  context.read<ProfileCubit>().updateProfile(
                    name: _name.text,
                    email: _emailOrMobile.text,
                    mobile: _mobile.text,
                    address: _address.text,
                    aboutUs: _aboutUs.text,
                    parentsGender: _parentGender,
                    parentName: _parentNameController.text,
                    babyBorned: _babyStatus == 'Baby is born',
                    babyAge: _babyAgeController.text,
                  );
                  Future.delayed(Duration(seconds: 2));
                  context.read<ProfileCompletionCubit>().getProfileCompletion();
                }
              },
            );
      },
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _emailOrMobile.dispose();
    _mobile.dispose();
    _address.dispose();
    _aboutUs.dispose();
    _parentNameController.dispose();
    _babyAgeController.dispose();
    super.dispose();
  }
}
