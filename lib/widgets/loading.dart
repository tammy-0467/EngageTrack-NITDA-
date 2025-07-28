import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingLine(),
    );
  }
}

class LoadingLine extends StatefulWidget {
  @override
  _LoadingLineState createState() => _LoadingLineState();
}

class _LoadingLineState extends State<LoadingLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 140.0, // Adjust the width as needed
        child: TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(seconds: 10),
          builder: (BuildContext context, double value, Widget? child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey,
              color: Color(0xff281537),
            );
          },
          onEnd: () {
            _controller.repeat(reverse: true);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
