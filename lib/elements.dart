import 'package:flutter/material.dart';

class PressableButton extends StatefulWidget {
  final Widget child; // Accept any widget as a child
  final EdgeInsets padding; // Accept padding as a parameter
  final VoidCallback? onPressed; // Optional onPressed callback

  PressableButton({
    Key? key,
    required this.child,
    required this.padding,
    this.onPressed, // Optional parameter
  }) : super(key: key);

  @override
  _PressableButtonState createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isPressed = true);
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() => _isPressed = false);
    if (widget.onPressed != null) {
      widget.onPressed!(); // Invoke the callback if it's not null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Color(0xFF59c977),
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Color(0xFF48a160),
                    offset: Offset(0, 5),
                    blurRadius: 0,
                  ),
                ],
        ),
        transform: _isPressed
            ? Matrix4.translationValues(0, 5, 0)
            : Matrix4.translationValues(0, 0, 0),
        child: widget.child,
      ),
    );
  }
}

class GreyContainer extends StatelessWidget {
  final Widget child; // Accept any widget as a child
  final EdgeInsets padding; // Accept padding as a parameter

  GreyContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(8.0), // Default padding if not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey[100], // Light grey color for the container
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!, // Darker grey color for the shadow
            offset: Offset(0, 5), // Shadow position
            blurRadius: 0, // No blur for a flat shadow
            spreadRadius: 0, // No spread to match the size of the container
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProgressBarWithPill extends StatefulWidget {
  final double initialProgress;

  const ProgressBarWithPill({Key? key, required this.initialProgress})
      : super(key: key);

  @override
  _ProgressBarWithPillState createState() => _ProgressBarWithPillState();
}

class _ProgressBarWithPillState extends State<ProgressBarWithPill> {
  late double progress;

  @override
  void initState() {
    super.initState();
    progress = widget.initialProgress;
  }

  // Imagine this method is called when the progress needs to be updated
  void updateProgress(double newProgress) {
    setState(() {
      progress = newProgress.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    double progressBarWidth =
        MediaQuery.of(context).size.width - 40; // Minus padding
    double pillWidth =
        progressBarWidth * progress * 0.8; // 80% of the progress bar width
    double pillLeftOffset = (progressBarWidth * progress - pillWidth) / 2;

    return Stack(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(
                10)), // This value controls the roundness of the corners
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF59c977)),
              minHeight: 20,
            )),
        Positioned(
          left: pillLeftOffset, // Center horizontally within the filled portion
          top: (20 - 10) /
              2, // Center vertically (20 is minHeight of progress bar, 5 is the desired height of the pill)
          bottom: (20 - 4) / 2,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: pillWidth,
            height: 4, // Desired height of the pill
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5), // Semi-transparent white
              borderRadius: BorderRadius.circular(10), // Pill shape
            ),
          ),
        ),
      ],
    );
  }
}
