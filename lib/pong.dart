import 'dart:math';
import 'package:flutter/material.dart';
import 'ball.dart';
import 'bat.dart';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  const Pong({Key? key}) : super(key: key);

  @override
  State<Pong> createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  int score = 0; // game score
  // Every time the ball bounces, we want to change the value of the random
  // number based on the border that is reached.
  double randX = 1; // a random number for the horizontal direction
  double randY = 1; // a random number for the vertical direction
  double ballDiameter = 50;
  double increment = 5; // ball move speed; higher is faster
  Direction vDir = Direction.down;
  Direction hDir = Direction.right;
  late Animation<double> animation;
  late AnimationController controller;
  double width = 0; // screen width
  double height = 0; // screen height
  double posX = 0; // ball x
  double posY = 0; // ball y
  double batWidth = 0;
  double batHeight = 0;
  double batPosition = 0; // bat horizontal position

  @override
  void initState() {
    posX = 0;
    posY = 0;

    controller = AnimationController(
      duration: const Duration(minutes: 10000),
      vsync: this,
    );

    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      safeSetState(() {
        moveBall();
      });
      checkBorders();
    });
    controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        batWidth = width / 5; // 20% of the screen width
        batHeight = height / 20; // 5% of the screen height

        return Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              right: 24,
              child: Text('Score: $score'),
            ),
            Positioned(
              top: posY,
              left: posX,
              child: const Ball(),
            ),
            Positioned(
              bottom: 0,
              left: batPosition,
              child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails update) =>
                    moveBat(update),
                child: Bat(batWidth, batHeight),
              ),
            ),
          ],
        );
      },
    );
  }

  void moveBat(DragUpdateDetails update) {
    safeSetState(() {
      batPosition += update.delta.dx;
    });
  }

  /// Checks which direction the ball is moving to, and incs or decs to its
  /// current position accordingly.
  void moveBall() {
    int incX = (increment * randX).round();
    (hDir == Direction.right) ? posX += incX : posX -= incX;

    int incY = (increment * randY).round();
    (vDir == Direction.down) ? posY += incY : posY -= incY;
  }

  /// Checks whether the ball has reached its border. and changes the
  /// direction whenever it has.
  void checkBorders() {
    // Left
    if (isBallLeft()) {
      hDir = Direction.right;
      randX = randomNumber();
    }
    // Right
    if (isBallRight()) {
      hDir = Direction.left;
      randX = randomNumber();
    }
    // Top
    if (isBallTop()) {
      vDir = Direction.down;
      randY = randomNumber();
    }
    // Bottom
    if (isBallBottom()) {
      // Check if the bat is here, otherwise lose
      if (isBatAlignedWithBall()) {
        vDir = Direction.up;
        randY = randomNumber();
        safeSetState(() {
          score++;
        });
      } else {
        controller.stop();
        dispose();
      }
    }
  }

  bool isBallLeft() => posX <= 0 && hDir == Direction.left;
  bool isBallRight() => posX >= width - ballDiameter && hDir == Direction.right;
  bool isBallTop() => posY <= 0 && vDir == Direction.up;
  bool isBallBottom() =>
      posY >= height - ballDiameter && vDir == Direction.down;
  bool isBatAlignedWithBall() =>
      posX >= (batPosition - ballDiameter) &&
      posX <= (batPosition + batWidth + ballDiameter);

  // When we call the dispose method on an object, the object is no longer
  // usable. Any subsequent call will raise an error. To prevent getting
  // errors prior to calling the setState method, we check whether the
  // controller is mounted and active.
  safeSetState(Function f) {
    if (mounted && controller.isAnimating) {
      setState(() {
        f();
      });
    }
  }

  double randomNumber() {
    int n = Random().nextInt(101);
    // a number between 0.5 and 1.5
    return (50 + n) / 100;
  }
}
