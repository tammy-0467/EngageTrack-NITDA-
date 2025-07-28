import "package:flutter/material.dart";

class CustomNavigation extends PageRouteBuilder {
  final Widget child;

  CustomNavigation({required this.child, }): super(transitionDuration: Duration(milliseconds: 300), reverseTransitionDuration: Duration(milliseconds: 300), pageBuilder: (context, animation, secondaryAnimation)=> child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child)=>
    SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset.zero
      ).animate(animation),
    child: child,
    );

/* {
    // TODO: implement buildPage
    return super.buildPage(context, animation, secondaryAnimation);
  }*/
}