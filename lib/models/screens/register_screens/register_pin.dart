import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transactions_app/models/services/auth_service.dart';
import 'package:transactions_app/models/user_model.dart';
import 'package:transactions_app/utils/constants.dart';
import 'package:transactions_app/widgets/app_button.dart';
import 'package:transactions_app/widgets/info.dart';

class RegisterPin extends StatefulWidget {
  const RegisterPin({Key? key}) : super(key: key);

  @override
  State<RegisterPin> createState() => _RegisterPinState();
}

class _RegisterPinState extends State<RegisterPin> {
  final _pinController = TextEditingController();
  bool _isValid = false;

  void _validatePin(String pin) {
    setState(() {
      _isValid = pin.length == 4 && !_isPalindrome(pin); // Check for palindrome
    });
  }

  bool _isPalindrome(String pin) {
    // Check if the PIN is a palindrome
    return pin == pin.split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        actions: const [Info()],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const LinearProgressIndicator(
            value: 4 / 4, // Adjust the value according to the registration step
            color: const Color(0xFF05BE71),
            minHeight: 8,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        child: Text(
                          Strings.pin,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 32),
                        child: Text(
                          Strings.pinDesc,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: Sizes.size380,
                          child: TextField(
                            controller: _pinController,
                            onChanged: (value) {
                              _validatePin(_pinController.text);
                            },
                            obscureText: true, // Hides the input
                            maxLength: 4, // Limit input to 4 digits
                            textAlign: TextAlign.start,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Pin',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 55),
                    child: AppButton(
                      title: Strings.next,
                      isValid: _isValid,
                      onTap: () {
                        if (_isValid) {
                          Provider.of<UserModel>(context, listen: false)
                              .setPin(_pinController.text);
                          // Proceed to the next registration step or complete registration
                          //Navigator.of(context).pushReplacement(MaterialPageRoute(
                          //   builder: (context) => const RegisterUsername()));
                          AuthService().signUp(
                            context,
                            username:
                                Provider.of<UserModel>(context, listen: false)
                                    .username!,
                            email:
                                Provider.of<UserModel>(context, listen: false)
                                    .email!,
                            password:
                                Provider.of<UserModel>(context, listen: false)
                                    .password!,
                            phone:
                                Provider.of<UserModel>(context, listen: false)
                                    .phone!,
                            pin: Provider.of<UserModel>(context, listen: false)
                                .pin!,
                            emergencyContact:
                                Provider.of<UserModel>(context, listen: false)
                                    .emergencyContact!,
                          );
                        } else {
                          // Show error message for palindrome PIN
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Invalid PIN'),
                                content: const Text(
                                    'Palindrome PIN is not allowed.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
