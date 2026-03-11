import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final double fontSize;

  const ExpandableTextWidget({super.key, required this.text, this.fontSize = 15});

  @override
  ExpandableTextWidgetState createState() => ExpandableTextWidgetState();
}

class ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;
  bool _hasMoreLines = false;

  @override
  Widget build(BuildContext context) {
    final int maxLines = 3;
    final TextStyle textStyle = TextStyle(
        fontSize: widget.fontSize, color: Theme.of(context).textTheme.bodyLarge!.color!);
    final String fullText = widget.text;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: fullText, style: textStyle),
      maxLines: 4,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    _hasMoreLines = textPainter.didExceedMaxLines;

    String truncatedText = fullText;
    if (!_isExpanded && _hasMoreLines) {
      textPainter.maxLines = maxLines;
      textPainter.layout(maxWidth: MediaQuery.of(context).size.width);

      final int cutOffIndex = textPainter
          .getPositionForOffset(
        Offset(
          MediaQuery.of(context).size.width,
          textPainter.height,
        ),
      )
          .offset;
      truncatedText = "${fullText.substring(0, cutOffIndex).trim()}... ";
    }

    return RichText(
      text: TextSpan(
        text: _isExpanded ? fullText : truncatedText,
        style: textStyle,
        children: _hasMoreLines ? [
          TextSpan(
            text: _isExpanded ? ' Show Less' : 'Show More',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
          ),
        ] : [],
      ),
    );
  }
}