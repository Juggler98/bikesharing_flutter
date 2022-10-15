import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class GoogleSignInButton extends StatelessWidget {
  final Function googleSignInTrigger;

  const GoogleSignInButton(this.googleSignInTrigger, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.all(0),
        //decoration: BoxDecoration(borderRadius: BorderRadius.circular(1.0)),
        child: SignInButton(
          Buttons.google,
          onPressed: () {
            googleSignInTrigger();
          },
          text: 'Pokračovať s Google',
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(
              color: Colors.black,
              width: 0.72,
            ),
          ),
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 1),
        ),
      ),
    );
  }
}
