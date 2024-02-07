import 'package:flutter/material.dart';
import 'package:project_rally/src/constants/constants.dart';

class SlidePageRoute<T> extends MaterialPageRoute<T> {
  final bool slideFromLeft;
  final Duration customTransitionDuration;

  SlidePageRoute({
    required super.builder,
    super.settings,
    this.slideFromLeft = true,
    this.customTransitionDuration = const Duration(milliseconds: AppConstants.slideAnimationDuration),
  });

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    Offset begin, end;
    if (slideFromLeft) {
      begin = const Offset(-1.0, 0.0);
      end = Offset.zero;
    } else {
      begin = const Offset(1.0, 0.0);
      end = Offset.zero;
    }

    var tween = Tween(begin: begin, end: end);
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => customTransitionDuration;
}