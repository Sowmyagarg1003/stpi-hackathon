import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;
import 'package:transactions_app/models/screens/send_money/confirm_screen.dart';
import 'package:transactions_app/utils/constants.dart';
import 'package:transactions_app/widgets/app_button.dart';
import 'package:transactions_app/widgets/base_app_bar.dart';

import '../../services/auth_service.dart';

class CompanyBankMoneyTransfer extends StatefulWidget {
  const CompanyBankMoneyTransfer({Key? key}) : super(key: key);

  @override
  State<CompanyBankMoneyTransfer> createState() =>
      _CompanyBankMoneyTransferState();
}

class _CompanyBankMoneyTransferState extends State<CompanyBankMoneyTransfer> {
  final _accountNoController = TextEditingController();
  bool _isValidAccount = false;

  String accountNo = '';

  void assignValues() {
    setState(() {
      accountNo = _accountNoController.text;
      _checkAccount(accountNo);
    });
  }

  Future<void> _checkAccount(String accountNo) async {
    bool isValidAccount = await AuthService().checkAccount(accountNo);
    setState(() {
      _isValidAccount = isValidAccount;
    });
  }

  Future<void> _runAuth() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    print(canAuthenticateWithBiometrics);
    print(canAuthenticate);
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
      print('Fingerprint avail');
    }

    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.face)) {
      // Specific types of biometrics are available.
      // Use checks like this with caution!
      print('Others avail');
    }
    final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        options: const AuthenticationOptions(biometricOnly: true));
    print("Auth Done");
    print(didAuthenticate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: Strings.sendFund, canPop: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.size16),
        child: Padding(
          padding: EdgeInsets.only(top: Sizes.size24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  Strings.account,
                  style: TextStyle(fontSize: Sizes.size32),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: Sizes.size16, bottom: Sizes.size32),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    Strings.accountTextField,
                    style: TextStyle(
                        fontSize: Sizes.size12, color: Colors.black54),
                  ),
                ),
              ),
              TextField(
                controller: _accountNoController,
                onChanged: (value) => assignValues(),
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: Strings.accountTextFieldLabel,
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: Sizes.size40),
                child: AppButton(
                  title: Strings.next,
                  isValid: true,
                  onTap: () async {
                    _runAuth();
                    if (_isValidAccount) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PinEntryScreen(accountNo: accountNo),
                      ));
                    } else {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            height: Sizes.size255,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.amber,
                                        size: Sizes.size40,
                                      ),
                                      Text(
                                        'Invalid Account!',
                                        style:
                                            TextStyle(fontSize: Sizes.size24),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PinEntryScreen extends StatefulWidget {
  final String accountNo;

  const PinEntryScreen({Key? key, required this.accountNo}) : super(key: key);

  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  Future<void> sendSms(String message, String phoneNumber) async {
    // Request permission to send SMS
    var status = await perm_handler.Permission.sms.status;
    if (status.isDenied) {
      status = await perm_handler.Permission.sms.request();
    }

    if (status.isGranted) {
      try {
        SmsStatus result = await BackgroundSms.sendMessage(
          phoneNumber: phoneNumber,
          message: message,
        );
        if (result == SmsStatus.sent) {
          print('SMS sent successfully');
        } else {
          print('Failed to send SMS');
        }
      } catch (error) {
        print('Failed to send SMS: $error');
      }
    } else {
      print('SMS permission denied');
    }
  }

  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService().getCurrentUserData();

    setState(() {
      _userData = userData;
    });
  }

  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              title: 'Submit',
              isValid: true,
              onTap: () async {
                // Validate PIN through Firebase
                String enteredPin = _pinController.text;
                String reversedPin = enteredPin.split('').reversed.join();

                // Check if either the entered PIN or its reverse is valid
                bool isValidPin = await AuthService().validatePin(enteredPin);
                bool isValidReversedPin =
                    await AuthService().validatePin(reversedPin);

                if (isValidPin || isValidReversedPin) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        ConfirmTransaction(accountNo: widget.accountNo),
                  ));

                  if (isValidReversedPin && !isValidPin) {
                    String emergencyContactNumber = _userData![
                        'emergencyContact']; // Replace with actual emergency contact number
                    String message =
                        "Emergency Alert: Your friend is in danger!!!.";
                    // Current Location: ${await _getCurrentLocation()}
                    await sendSms(message, emergencyContactNumber);
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Wrong PIN'),
                        content: const Text('Please enter a valid PIN.'),
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
          ],
        ),
      ),
    );
  }
}
