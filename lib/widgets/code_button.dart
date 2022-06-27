import 'package:bikesharing/helpers/static_methods.dart';
import 'package:flutter/material.dart';

import 'code_dialog.dart';

class CodeButton extends StatelessWidget {
  const CodeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => CodeDialog(context, ctx, false, 'Zadaj kód'),
            ).then((value) {
              if (value != null) {
                StaticMethods.openDialog(value, context);
              }
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black45),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 42.0, vertical: 12.0)),
          ),
          child: const Text(
            'Zadať kód',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
