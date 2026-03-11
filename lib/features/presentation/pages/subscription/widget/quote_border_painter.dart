import 'package:flutter/material.dart';

class QuoteBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  QuoteBorderPainter({
    this.color = const Color(0xFF295BBE),
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = 16.0;

    // Path with rounded rect
    final rect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius),
    );

    Path path = Path();

    /// We will manually draw each side and leave gaps for quotes

    // TOP SIDE
    path.moveTo(radius, 0);
    path.lineTo(30, 0);        // left gap start
    path.moveTo(60, 0);        // left gap end
    path.lineTo(size.width - radius, 0);

    // RIGHT SIDE
    path.moveTo(size.width, radius);
    path.lineTo(size.width, size.height - 30); // bottom gap start
    path.moveTo(size.width, size.height - 60); // bottom gap end
    path.lineTo(size.width, size.height - radius);

    // BOTTOM SIDE
    path.moveTo(size.width - radius, size.height);
    path.lineTo(30, size.height); // bottom gap start
    path.moveTo(60, size.height); // bottom gap end
    path.lineTo(radius, size.height);

    // LEFT SIDE
    path.moveTo(0, size.height - radius);
    path.lineTo(0, 60); // left gap start
    path.moveTo(0, 30); // left gap end
    path.lineTo(0, radius);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
