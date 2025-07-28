import 'dart:math';

import 'package:flutter/material.dart';

class Display1 extends StatefulWidget {
  const Display1({Key? key});

  @override
  State<Display1> createState() => _DisplayState();
}

class _DisplayState extends State<Display1>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> flipAnim;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat();
    flipAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.5, curve: Curves.linear),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animations'),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Transform(
              transform: Matrix4.identity()..rotateY(2 * pi * (flipAnim.value)),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/bonus4.png',
                height: 15,
                width: 15,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
