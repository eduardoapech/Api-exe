import 'dart:async';

import 'package:flutter/material.dart';

class Time extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _TimeState();
}

class _TimeState extends State<Time> {
  late Timer timer;
  FlutterLogoStyle _logoStyle = FlutterLogoStyle.markOnly;

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _logoStyle = FlutterLogoStyle.horizontal;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new FlutterLogo(
      size: 200.0,
      textColor: Colors.white, // Assuming Palette.white is a custom color
      style: _logoStyle,
    );
  }
}
