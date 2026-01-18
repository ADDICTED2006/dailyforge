import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class StreakCelebration extends StatefulWidget {
  final Widget child;
  final bool play;
  final VoidCallback onFinished;

  const StreakCelebration({
    Key? key, 
    required this.child, 
    required this.play,
    required this.onFinished,
  }) : super(key: key);

  @override
  State<StreakCelebration> createState() => _StreakCelebrationState();
}

class _StreakCelebrationState extends State<StreakCelebration> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didUpdateWidget(StreakCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _controllerCenter.play();
      // Notify parent after animation duration
      Future.delayed(const Duration(seconds: 4), () {
         widget.onFinished();
      });
    }
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirectionality: BlastDirectionality.explosive, // radial value - LEFT
            shouldLoop: false, 
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // manually specify the colors to be used
            createParticlePath: drawStar, // define a custom shape/path.
          ),
        ),
      ],
    );
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = 360 / numberOfPoints;
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degToRad(degreesPerStep)) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + degToRad(halfDegreesPerStep)),
          halfWidth + internalRadius * sin(step + degToRad(halfDegreesPerStep)));
    }
    path.close();
    return path;
  }
}
