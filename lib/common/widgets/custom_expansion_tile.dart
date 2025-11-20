import '../../core/constant/app_export.dart';
import 'package:flutter/material.dart';

class RecipeStepTile extends StatefulWidget {
  final int stepNumber;
  final String title;
  final String description;
  final Color color;

  const RecipeStepTile({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  State<RecipeStepTile> createState() => _RecipeStepTileState();
}

class _RecipeStepTileState extends State<RecipeStepTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          // color: Theme.of(context).cardColor,
          color: widget.color,
          borderRadius: BorderRadius.circular(5.0),
        ),

        padding: EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Text(
                      widget.stepNumber.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Title and triangle
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.play_arrow, color: Colors.red, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              // Description (shown only when expanded)
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 28),
                  child: Text(
                    widget.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
