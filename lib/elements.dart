import 'dart:math';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'auth.dart';

class PressableButton extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;

  const PressableButton({
    Key? key,
    required this.child,
    required this.padding,
    this.color = const Color.fromARGB(255, 243, 243, 243),
    this.shadowColor = const Color.fromARGB(255, 216, 216, 216),
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
        duration: const Duration(milliseconds: 100),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              _isPressed
                  ? []
                  : [
                    BoxShadow(
                      color: widget.shadowColor,
                      offset: const Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
        ),
        transform:
            _isPressed
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

  const GreyContainer({
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
            offset: const Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class GreenContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GreenContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 243, 243),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: const Color.fromARGB(255, 216, 216, 216),
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
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF59c977)),
            minHeight: 20,
          ),
        ),
        Positioned(
          left: pillLeftOffset,
          top: (20 - 10) / 2,
          bottom: (20 - 4) / 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
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
  final VoidCallback onDismiss;

  const NoConnectionWidget({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Keine Internetverbindung',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4.0),
              Text(
                'Bitte stellen sie eine Verbindung her',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.grey[800], size: 20.0),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthenticateWidget extends StatelessWidget {
  final VoidCallback onDismiss;
  final Function(bool) setAuthenticated;
  final VoidCallback setQuestionnairDone;

  const AuthenticateWidget({
    super.key,
    required this.onDismiss,
    required this.setAuthenticated,
    required this.setQuestionnairDone,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          LoginScreen(setAuthenticated: setAuthenticated),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bitte über Login anmelden',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Sie müssen sich anmelden, um fortzufahren.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.grey[800], size: 20.0),
            ),
          ),
        ),
      ],
    );
  }
}

class DismissButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DismissButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.grey[800], size: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}

class SpeechBubble extends StatelessWidget {
  final String message;

  const SpeechBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      // Added Material widget
      color: Colors.transparent, // Make sure the background remains transparent
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main bubble
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Triangle (pointer)
          Positioned(
            left: -10,
            top: 15,
            child: CustomPaint(painter: TrianglePainter()),
          ),
        ],
      ),
    );
  }
}

class CoinsOverlay extends StatefulWidget {
  @override
  _CoinsOverlayState createState() => _CoinsOverlayState();
}

class _CoinsOverlayState extends State<CoinsOverlay>
    with SingleTickerProviderStateMixin {
  final List<Offset> _coinPositions = [];
  final Random _random = Random();
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    _generateCoins();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _animate = true;
      });
    });
  }

  void _generateCoins() {
    for (int i = 0; i < 100; i++) {
      double x = _random.nextDouble() * 300 + 50; // Random X position
      double y = 600 + _random.nextDouble() * 50; // Bottom region
      _coinPositions.add(Offset(x, y));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          _coinPositions.map((position) {
            int index = _coinPositions.indexOf(position);
            return AnimatedPositioned(
              duration: Duration(milliseconds: 1500 + _random.nextInt(500)),
              curve: Curves.easeInOut,
              left:
                  _animate
                      ? MediaQuery.of(context).size.width - 50
                      : position.dx,
              top: _animate ? 50 : position.dy,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 1500),
                opacity: _animate ? 0.0 : 1.0,
                child: Icon(Icons.circle, size: 12, color: Colors.amber),
              ),
            );
          }).toList(),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    var path = Path();
    // Start from the right point of the triangle
    path.moveTo(10, 0); // Start at the top-right corner
    // Draw a line to the left point
    path.lineTo(0, 5); // This is the tip of the triangle pointing left
    // Draw a line to the bottom-right corner
    path.lineTo(10, 10);
    // Close the path to form the triangle
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ResultAnimation extends StatefulWidget {
  final bool isCorrect;
  final VoidCallback onAnimationEnd;

  const ResultAnimation({
    Key? key,
    required this.isCorrect,
    required this.onAnimationEnd,
  }) : super(key: key);

  @override
  _ResultAnimationState createState() => _ResultAnimationState();
}

class _ResultAnimationState extends State<ResultAnimation> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // Auto-hide animation after playing
    Future.delayed(Duration(milliseconds: 1300), () {
      if (mounted) {
        setState(() => _isVisible = false);
        widget.onAnimationEnd(); // Notify parent to clean up
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return SizedBox.shrink(); // Hide widget when done

    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 800),
        child: Lottie.asset(
          widget.isCorrect ? 'assets/correct.json' : 'assets/wrong.json',
          repeat: false,
        ),
      ),
    );
  }
}

Widget buildIconButton(IconData icon, Function() onPressed) {
  if (Icons.sync == icon) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
      child: NeumorphicIcon(
        icon,
        size: 52,
        style: NeumorphicStyle(color: Colors.blue, depth: 2),
      ),
    );
  }

  if (Icons.delete == icon) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: NeumorphicIcon(
        icon,
        size: 60,
        style: NeumorphicStyle(color: Colors.grey[400], depth: 2),
      ),
    );
  }

  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    child: NeumorphicIcon(icon, size: 60, style: NeumorphicStyle(depth: 2)),
  );
}

void showErrorDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Neumorphic(
            style: NeumorphicStyle(
              depth: 8,
              color: Colors.grey[200], // Light background
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.error,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  NeumorphicButton(
                    onPressed: () => Navigator.pop(context),
                    style: NeumorphicStyle(
                      depth: 4,
                      color: Colors.redAccent,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.ok,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void showMessageDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Neumorphic(
            style: NeumorphicStyle(
              depth: 8,
              color: Colors.grey[200], // Light background
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info, color: Colors.blueAccent, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.message,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  NeumorphicButton(
                    onPressed: () => Navigator.pop(context),
                    style: NeumorphicStyle(
                      depth: 4,
                      color: Colors.blueAccent,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.ok,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
