import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final Color? color;
  final bool? androidIndicator;

  const CustomProgressIndicator({
    this.color,
    this.androidIndicator = false,
    Key? key,
  }) : super(key: key);

  // return jumpingDotsProgressIndicator(
  // fontSize: 32,
  // color: Colors.black54,
  // );

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = isDarkMode ? Colors.grey[400] : Colors.green;
    final isAndroid = Platform.isAndroid;
    return isAndroid || androidIndicator!
        ? CircularProgressIndicator(
            color: this.color ?? color,
          )
        : CupertinoActivityIndicator(
            color: this.color,
            radius: 14,
          );
  }
}
