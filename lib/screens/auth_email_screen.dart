import 'dart:io';

import 'package:flutter/material.dart';

import 'auth_form.dart';

class AuthEmailScreen extends StatelessWidget {
  final bool isLogin;

  const AuthEmailScreen(this.isLogin, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(253, 248, 248, 253),
          ),
          SizedBox(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FittedBox(
                        child: Text(
                          !isLogin ? 'Zaregistruj sa' : 'Prihlás sa',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/bikesharing.png',
                        width: 100,
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            !isLogin
                                ? 'Zaregistruj sa a začni jazdiť.'
                                : 'Prihlás sa a začni jazdiť.',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthForm(isLogin),
                      const SizedBox(height: 4),
                      //const DocumentAgree(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              title: const Text(''),
              // You can add title here
              leading: IconButton(
                icon: Platform.isAndroid
                    ? const Icon(Icons.arrow_back, color: Colors.grey)
                    : const Icon(Icons.arrow_back_ios, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.blue.withOpacity(0.0),
              //You can make this transparent
              elevation: 0.0, //No shadow
            ),
          ),
        ],
      ),
    );
  }
}
