import 'package:flutter/material.dart';
import 'dart:math';

enum AnimationDirection {
  forward,
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
  fadeIn,
  fadeOut,
  spray,
  zoomIn,
  zoomOut,
  rotate,
  assemble,
  disintegrate,
}

class AnimatedWrapper extends StatefulWidget {
  final Widget child;
  final AnimationDirection direction;
  final Duration duration;

  const AnimatedWrapper({super.key,
    required this.child,
    this.direction = AnimationDirection.forward,
    this.duration = const Duration(seconds: 2),
  });

  @override
  _AnimatedWrapperState createState() => _AnimatedWrapperState();
}

class _AnimatedWrapperState extends State<AnimatedWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset>? _slideAnimation;
  late Animation<double>? _fadeAnimation;
  late Animation<double>? _scaleAnimation;
  late Animation<double>? _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    switch (widget.direction) {
      case AnimationDirection.leftToRight:
        _slideAnimation = Tween<Offset>(
          begin: Offset(-1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case AnimationDirection.rightToLeft:
        _slideAnimation = Tween<Offset>(
          begin: Offset(1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case AnimationDirection.topToBottom:
        _slideAnimation = Tween<Offset>(
          begin: Offset(0, -1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case AnimationDirection.bottomToTop:
        _slideAnimation = Tween<Offset>(
          begin: Offset(0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case AnimationDirection.fadeIn:
        _fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case AnimationDirection.fadeOut:
        _fadeAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case AnimationDirection.zoomIn:
        _scaleAnimation = Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case AnimationDirection.zoomOut:
        _scaleAnimation = Tween<double>(
          begin: 1.0,
          end: 0.5,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      case AnimationDirection.rotate:
        _rotationAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        break;
      default:
        _slideAnimation = Tween<Offset>(
          begin: Offset(1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }
  }

  Widget _assembleAnimation() {
    return Stack(
      children: List.generate(10, (index) {
        final random = Random();
        double xOffset = (random.nextDouble() * 300) - 150; // Random horizontal position
        double yOffset = (random.nextDouble() * 300) - 150; // Random vertical position

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(xOffset * (1 - _controller.value), yOffset * (1 - _controller.value)),
              child: Opacity(
                opacity: _controller.value,
                child: widget.child,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _disintegrateAnimation() {
    return Stack(
      children: List.generate(10, (index) {
        final random = Random();
        double xOffset = (random.nextDouble() * 300) - 150; // Random horizontal scatter
        double yOffset = (random.nextDouble() * 300) - 150; // Random vertical scatter

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(xOffset * _controller.value, yOffset * _controller.value),
              child: Opacity(
                opacity: 1 - _controller.value,
                child: widget.child,
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.direction) {
      case AnimationDirection.assemble:
        return _assembleAnimation();
      case AnimationDirection.disintegrate:
        return _disintegrateAnimation();
      case AnimationDirection.fadeIn:
      case AnimationDirection.fadeOut:
        return FadeTransition(
          opacity: _fadeAnimation!,
          child: widget.child,
        );
      case AnimationDirection.zoomIn:
      case AnimationDirection.zoomOut:
        return ScaleTransition(
          scale: _scaleAnimation!,
          child: widget.child,
        );
      case AnimationDirection.rotate:
        return RotationTransition(
          turns: _rotationAnimation!,
          child: widget.child,
        );
      default:
        return SlideTransition(
          position: _slideAnimation!,
          child: widget.child,
        );
    }
  }
}
