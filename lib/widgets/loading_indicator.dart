import 'package:flutter/material.dart';

class Custom_circular_Indicator extends StatelessWidget {
  const Custom_circular_Indicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.14,
        width: MediaQuery.of(context).size.width * 0.32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black.withOpacity(0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              CircularProgressIndicator(
                backgroundColor: Colors.red,
                //value: 0.2,
                strokeWidth: 3,
              ),
              SizedBox(
                height: 7,
              ),
              Text(
                'Loading...',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  height: 1.0,
                  fontSize: 10,
                  color: Colors.white,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Text(
                'please wait',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  height: 1.0,
                  fontSize: 10,
                  color: Colors.white,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ],
          ),
        ));
  }
}
