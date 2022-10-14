import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';
import '../widgets/progress_indicator.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;

  const AuthForm(this.isLogin, {Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userPassword = '';
  final _passwordController = TextEditingController();
  var _obscureText = true;

  var _isLoading = false;

  // var _badPasswordCount = 0;

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusManager.instance.primaryFocus!.unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      _submitAuthForm(_userEmail.trim(), _userPassword.trim(), widget.isLogin);
    }
  }

  Future<void> _submitAuthForm(
    String email,
    String password,
    bool isLogin,
  ) async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (isLogin) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(email, password);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(email, password);
      }
      Navigator.of(context).pop();
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Okay')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2.0,
      child: Container(
        width: deviceSize.width * 0.80,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const ValueKey('email'),
                  style: buildTextStyle,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value!.trim().isEmpty || !value.contains('@')) {
                      return 'Zadaj platnú mailovú adresu';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: buildHintTextStyle,
                    focusedBorder: buildBorder,
                    enabledBorder: buildBorder,
                  ),
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                TextFormField(
                  key: const ValueKey('password'),
                  style: buildTextStyle,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 6) {
                      return 'Zadaj viac znakov';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Heslo',
                    labelStyle: buildHintTextStyle,
                    focusedBorder: buildBorder,
                    enabledBorder: buildBorder,
                    suffixIcon: IconButton(
                      icon: _obscureText
                          ? const Icon(
                              Icons.remove_red_eye,
                              color: Colors.grey,
                            )
                          : const Icon(Icons.remove_red_eye_outlined,
                              color: Colors.green),
                      onPressed: () => setState(() {
                        _obscureText = !_obscureText;
                      }),
                    ),
                  ),
                  controller: _passwordController,
                  obscureText: _obscureText,
                  onSaved: (value) {
                    _userPassword = value!;
                  },
                ),
                if (!widget.isLogin)
                  TextFormField(
                    enabled: !widget.isLogin,
                    style: buildTextStyle,
                    decoration: InputDecoration(
                      labelText: 'Potvrď heslo',
                      labelStyle: buildHintTextStyle,
                      focusedBorder: buildBorder,
                      enabledBorder: buildBorder,
                    ),
                    obscureText: _obscureText,
                    validator: !widget.isLogin
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Heslá sa nezhodujú';
                            }
                            return null;
                          }
                        : (value) {
                            return null;
                          },
                  ),
                const SizedBox(height: 12),
                if (_isLoading)
                  SizedBox(
                      width: 48,
                      height: 48,
                      child: CustomProgressIndicator(
                          color: Platform.isAndroid
                              ? Colors.green
                              : Colors.black)),
                if (!_isLoading)
                  ElevatedButton(
                    onPressed: _trySubmit,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0)),
                    ),
                    child: Text(
                      widget.isLogin ? 'Prihlás sa' : 'Zaregistruj sa',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get buildHintTextStyle => const TextStyle(color: Colors.black54);

  TextStyle get buildTextStyle => const TextStyle(color: Colors.black);

  UnderlineInputBorder get buildBorder {
    return const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey,
        width: 1,
      ),
    );
  }
}
