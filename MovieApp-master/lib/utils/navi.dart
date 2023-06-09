import 'package:flutter/material.dart';
import 'package:mov/screens/home_screen.dart';

Future newScreen(
    {required Function newScreen, required BuildContext context}) async {
  await Navigator.push(
    context,
    // MaterialPageRoute(builder: (context) => newScreen()),
    MaterialPageRoute(builder: (context) => HomeScreen()),
  );
}
