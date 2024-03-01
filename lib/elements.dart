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
