import 'package:flutter/material.dart';

import '../screens/scanner_screen.dart';

class ScannerButton extends StatelessWidget {
  const ScannerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.settings_overscan),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ScannerScreen(),
              ),
            );
          },
          label: const Text(
            'Naskenovať',
            style: TextStyle(fontSize: 16),
          ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 42.0, vertical: 12.0)),
          ),
        ),
      ),
    );
  }
}
