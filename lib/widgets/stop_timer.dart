import 'dart:async';

import 'package:flutter/material.dart';

class StopTimer extends StatefulWidget {
  final DateTime start;

  const StopTimer(this.start, {Key? key}) : super(key: key);

  @override
  _StopTimerState createState() => _StopTimerState();
}

class _StopTimerState extends State<StopTimer> {
  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() {});
      } else {
        t.cancel();
      }
    });
    return Row(
      children: [
        Text(
          _time,
          style: _buildTextStyle,
        ),
      ],
    );
  }

  String get _time {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String text = '';
    final duration = DateTime.now().difference(widget.start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      text += twoDigits(hours) + ':';
    }
    text += twoDigits(minutes) + ':' + twoDigits(seconds);
    return text;
  }

  TextStyle get _buildTextStyle {
    return const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
  }
}
