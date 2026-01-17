import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../core/constant/app_export.dart';

class CustomCarousel<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double height;
  final bool autoPlay;
  final double viewportFraction;
  final bool enlargeCenterPage;
  final int initialPage;

  const CustomCarousel({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.height = 180,
    this.autoPlay = true,
    this.viewportFraction = 0.8,
    this.enlargeCenterPage = false,
    this.initialPage = 0,
  });

  @override
  State<CustomCarousel<T>> createState() => _CustomCarouselState<T>();
}

class _CustomCarouselState<T> extends State<CustomCarousel<T>> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink(); // Or a placeholder widget if desired
    }
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index, int pageViewIndex) {
            return widget.itemBuilder(context, widget.items[index], index);
          },
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            height: widget.height,
            autoPlay: widget.autoPlay,
            enlargeCenterPage: widget.enlargeCenterPage,
            viewportFraction: widget.viewportFraction,
            animateToClosest: true,
            initialPage: widget.initialPage,
            disableCenter: true,
          ),
        ),
        //const SizedBox(height: 9),
        // Align(
        //   alignment: Alignment.center,
        //   child: CarouselIndicator(
        //     count: widget.items.length,
        //     index: _currentIndex,
        //     color: Colors.grey,
        //     activeColor: Color(AppColor.primaryColor),
        //     height: 10,
        //     width: 10,
        //   ),
        // ),
      ],
    );
  }
}