import 'dart:ui';
import 'package:flutter/material.dart';

class GlassMorphism extends StatelessWidget {
  final double? borderRadius;
  final double? blur;
  final double? opacity;
  final Color? backgroundColor;
  final Widget child;

  const GlassMorphism({
    super.key,
    this.borderRadius,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.backgroundColor = Colors.white,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0.0),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur ?? 10.0, sigmaY: blur ?? 10.0),
          child: child),
    );
  }
}
