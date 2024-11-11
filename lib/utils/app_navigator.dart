import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class AppNavigator {
  static void push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageTransition(
        child: page,
        type: PageTransitionType.fade,
      ),
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(child: page, type: PageTransitionType.fade),
      (route) => false,
    );
  }

  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageTransition(child: page, type: PageTransitionType.fade),
    );
  }
}
