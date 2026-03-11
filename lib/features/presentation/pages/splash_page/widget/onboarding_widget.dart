import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:tinydroplets/core/constant/app_fonts.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';

import '../../../../../core/constant/app_export.dart';
import '../../auth/login_page/login_page.dart';

class OnboardingWidget extends StatelessWidget {
  final String babyImage;
  final String title;
  final String content;
  final VoidCallback onTap;

  const OnboardingWidget({
    super.key,
    required this.babyImage,
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0F9FB),
      body: Stack(
        children: [
          // Background base
          Positioned(
            bottom: -12.h,
            left: -30.w,
            right: -30.w,
            height: 60.h,
            child: Image.asset(
              AppVector.bgBase,
              width: 100.w,
              fit: BoxFit.fill,
            ),
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 1.h,
            right: 4.w,
            child: TextButton(
              onPressed: () => gotoReplacement(context, LoginPage()),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontFamily: AppFonts.bobbyRough
                ),
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: 25.h),

              // Baby Image
              Expanded(
                flex: 6,
                child: Image.asset(
                  babyImage,
                  width: 100.w,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 1.h),

              // Text + Button
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 2.h),

                      // Content
                      Text(
                        content,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 1.h),

                      // Arrow Button
                      GestureDetector(
                        onTap: onTap,
                        child: Image.asset(
                          AppVector.arrowNext,
                          height: 10.h,
                        ),
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}