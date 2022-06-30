import 'package:flutter/material.dart';
import 'ball.dart';
import 'bat.dart';

class Pong extends StatefulWidget {
  const Pong({Key? key}) : super(key: key);

  @override
  State<Pong> createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late double width; // screen width
  late double height; // screen height
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
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    super.initState();
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
            const Positioned(
              top: 0,
              child: Ball(),
            ),
            Positioned(
              bottom: 0,
              child: Bat(batWidth, batHeight),
            ),
          ],
        );
      },
    );
  }
}
