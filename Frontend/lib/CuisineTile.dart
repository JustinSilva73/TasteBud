import 'package:flutter/material.dart';
import 'package:tastebud/TodayPop.dart';

class CuisineTile extends StatefulWidget {
  final String cuisine;
  final bool isSelected;
  final Function(bool, int)? onSelected;
  final int answerIndex; // New parameter for the answer index

  CuisineTile({
    Key? key,
    required this.cuisine,
    this.isSelected = false,
    this.onSelected,
    required this.answerIndex,
  }) : super(key: key);


  @override
  _CuisineTileState createState() => _CuisineTileState();
}

class _CuisineTileState extends State<CuisineTile> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onSelected != null) {
          widget.onSelected!(!widget.isSelected, widget.answerIndex);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.5), // Color of the border
            width: 0.75, // Width of the border
          ),
          gradient: isSelected
              ? LinearGradient(
            colors: [
              Color(0xFFA30000).withOpacity(0.6), // Dark color
              Color(0xFFA30000).withOpacity(0.17), // Lighter color, with opacity for gradient effect
            ],
            begin: Alignment.centerRight, // Start the gradient from the right
            end: Alignment(-0.3, 0.0), // End the gradient 65% from the right towards the center
          )
              : null, // Use null for no gradient in the non-selected state
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: isSelected ? null : const Color(0xFFA30000).withOpacity(0.17), // Add a fallback color when not selected
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: const Color(0xFFA30000), // Adjust icon color based on selection
            ),
            SizedBox(width: 10),
            Text(
              widget.cuisine,
              style: TextStyle(
                color: Colors.black, // Adjust text color based on selection
                fontSize: 18,
                fontFamily: 'Kadwa',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
