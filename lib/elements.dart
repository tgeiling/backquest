import 'package:flutter/material.dart';

class PressableButton extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;

  PressableButton({
    Key? key,
    required this.child,
    required this.padding,
    this.color = const Color(0xFF59c977),
    this.shadowColor = const Color(0xFF48a160),
    this.onPressed,
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
      widget.onPressed!();
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
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor,
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
  final Widget child;
  final EdgeInsets padding;

  GreyContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            offset: Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
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

  void updateProgress(double newProgress) {
    setState(() {
      progress = newProgress.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    double progressBarWidth = MediaQuery.of(context).size.width - 40;
    double pillWidth = progressBarWidth * progress * 0.8;
    double pillLeftOffset = (progressBarWidth * progress - pillWidth) / 2;

    return Stack(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF59c977)),
              minHeight: 20,
            )),
        Positioned(
          left: pillLeftOffset,
          top: (20 - 10) / 2,
          bottom: (20 - 4) / 2,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: pillWidth,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class NoConnectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Keine Internetverbindung',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.0),
        Text(
          'Bitte überprüfen Sie Ihre Netzwerkeinstellungen.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class AuthenticateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bitte über Login authentifizieren',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.0),
        Text(
          'Sie müssen sich anmelden, um fortzufahren.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
