import 'package:sizer/sizer.dart';
import 'package:tinydroplets/core/constant/app_vector.dart';
import 'package:tinydroplets/features/presentation/pages/splash_page/widget/onboarding_widget.dart';

import '../../../../core/constant/app_export.dart';
import '../auth/login_page/login_page.dart';
import 'package:flutter/material.dart';

class NewOnboardingPage extends StatefulWidget {
  const NewOnboardingPage({super.key});

  @override
  State<NewOnboardingPage> createState() => _NewOnboardingPageState();
}

class _NewOnboardingPageState extends State<NewOnboardingPage> {
  late final List<Widget> _pages;

  @override
  void initState() {
    _pages = [
      OnboardingWidget(
        babyImage: AppVector.babyImage2,
        title: '500+ QUICK & HEALTHY RECIPES',
        content:
        'FOR BABIES & TODDLERS – EASY, NUTRITIOUS MEALS DESIGNED TO SUPPORT YOUR CHILD\'S GROWTH AT EVERY STAGE.',
        onTap: _nextPage,
      ),
      OnboardingWidget(
        babyImage: AppVector.babyImage3,
        title: 'TRACK BABY MILESTONES',
        content: "Stay informed and confident through every stage of your child's growth.",
        onTap: _nextPage,
      ),
      OnboardingWidget(
        babyImage: AppVector.babyImage4,
        title: 'AGE-SPECIFIC MEAL PLANS',
        content: "Follow expertly crafted meal plans tailored to your baby's developmental needs",
        onTap: _nextPage,
      ),
      OnboardingWidget(
        babyImage: AppVector.babyImage8,
        title: 'FUN & EDUCATIONAL KIDS ACTIVITIES',
        content: "Boost learning and development with expert backed play ideas.",
        onTap: _nextPage,
      ),
    ];

    SharedPref.setOnboardingViewed(true);
    super.initState();
  }

  int _currentPage = 0;

  final PageController _controller = PageController();

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      gotoReplacement(context, LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDE59),
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) => _pages[index],
      ),
    );
  }
}
