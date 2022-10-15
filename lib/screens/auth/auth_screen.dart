import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/material.dart';

import '../../widgets/buttons/google_signin_button.dart';
import '../../widgets/progress_indicator.dart';
import 'auth_email_screen.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _googleSignIn = GoogleSignIn();

  // void _googleLogin() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   GoogleSignInAccount? user;
  //   try {
  //     user = await _googleSignIn.signIn();
  //   } catch (error) {
  //     if (kDebugMode) {
  //       print('Error _googleLogin(): $error');
  //     }
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     return;
  //   }
  //   if (user == null) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     return;
  //   } else {
  //     final googleAuth = await user.authentication;
  //
  //     final oauthCredential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     _signIn(oauthCredential);
  //   }
  // }

  // void _signIn(OAuthCredential oAuthCredential) async {
  //
  //
  //   // setState(() {
  //   //   _isLoading = false;
  //   // });
  //
  //   // await _googleSignIn.disconnect();
  //   // FirebaseAuth.instance.signOut();
  // }

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/bike.png',
                            width: 48,
                          ),
                          const SizedBox(width: 5),
                          const FittedBox(
                            child: Text(
                              'BIKESHARING',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/bikesharing.png',
                        width: 100,
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'Nestoj v zápche, sadni ZA bike.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const CustomProgressIndicator(
                          color: Colors.green,
                          androidIndicator: true,
                        ),
                      if (_isLoading)
                        const SizedBox(height: 20)
                      else
                        const SizedBox(height: 56),
                      GoogleSignInButton(() {}),
                      Row(
                        children: const [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 12.0),
                              child: Divider(color: Colors.grey),
                            ),
                          ),
                          Text(
                            'alebo',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 12.0),
                              child: Divider(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (!_isLoading) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        const AuthEmailScreen(false),
                                  ),
                                );
                              }
                            },
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    Size(deviceSize.width / 3, 36))),
                            child: const Text(
                              'Zaregistruj sa',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () {
                              if (!_isLoading) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        const AuthEmailScreen(true),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              primary: Colors.green,
                              side: const BorderSide(
                                  width: 1, color: Colors.green),
                              minimumSize: Size(deviceSize.width / 3, 36),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Prihlás sa',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      //const DocumentAgree(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
