  import 'package:tinydroplets/core/constant/app_export.dart';
  import 'package:tinydroplets/features/presentation/pages/auth/login_page/login_page.dart';
  import 'package:tinydroplets/features/presentation/pages/dashboard/dashboard.dart';

  class OnboardingScreen extends StatefulWidget {
    const OnboardingScreen({super.key});

    @override
    OnboardingScreenState createState() => OnboardingScreenState();
  }

  class OnboardingScreenState extends State<OnboardingScreen> {
    @override
    void initState() {
      super.initState();
      SharedPref.setOnboardingViewed(true);
    }

    final PageController _pageController = PageController();
    int _currentPage = 0;
    final List<Widget> _pages = [
      AnimatedWrapper(
        direction: AnimationDirection.forward,
        child: OnboardingPage(
          image: Icons.shopping_bag,
          title: "Buy with Ease",
          description:
              "Purchase eBooks effortlessly and start your reading journey.",
        ),
      ),
      AnimatedWrapper(
        direction: AnimationDirection.forward,
        child: OnboardingPage(
          image: Icons.headphones,
          title: "Listen to eBooks",
          description: "Enjoy audiobooks anywhere, anytime with ease.",
        ),
      ),
      AnimatedWrapper(
        direction: AnimationDirection.forward,
        child: OnboardingPage(
          image: Icons.menu_book,
          title: "Read Your Favorites",
          description:
              "Access a vast library of eBooks to read at your convenience.",
        ),
      ),
    ];

    void _onPageChanged(int index) {
      setState(() {
        _currentPage = index;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _pages[index],
            ),
            Positioned(
              top: 40,
              right: 20,
              child: TextButton(
                onPressed: () {
                  gotoReplacement(context, LoginPage());
                },
                child: Text("Skip", style: TextStyle(fontSize: 16)),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: AppButton(
                useCupertino: true,
                width: 100,
                text: _currentPage == _pages.length - 1 ? "Finish" : "Next",
                onPressed: () async {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    gotoReplacement(context, LoginPage());
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildDot(int index) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        height: 10,
        width: _currentPage == index ? 12 : 8,
        decoration: BoxDecoration(
          color:
              _currentPage == index ? Color(AppColor.primaryColor) : Colors.grey,
          shape: BoxShape.circle,
        ),
      );
    }
  }

  class OnboardingPage extends StatelessWidget {
    final IconData image;
    final String title;
    final String description;

    const OnboardingPage({
      super.key,
      required this.image,
      required this.title,
      required this.description,
    });

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(image, size: 150, color: Color(AppColor.primaryColor)),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }
