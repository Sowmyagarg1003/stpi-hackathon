import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transactions_app/models/user_model.dart';
import 'package:transactions_app/utils/constants.dart';
import 'package:transactions_app/utils/country_phone_codes.dart';
import 'package:transactions_app/widgets/app_button.dart';
import 'package:transactions_app/widgets/info.dart';

import 'register_pin.dart'; // Import RegisterPin screen

class RegisterPhone extends StatefulWidget {
  const RegisterPhone({Key? key}) : super(key: key);

  @override
  State<RegisterPhone> createState() => _RegisterPhoneState();
}

class _RegisterPhoneState extends State<RegisterPhone> {
  final List<Map<String, String>> countryPhoneCodes =
      CountryPhoneCodes().phoneList;
  final _phoneController = TextEditingController();
  final _emergencyPhoneController =
      TextEditingController(); // Controller for emergency contact number
  bool _isValid = false;

  String dropdownValue = "+91";

  Future<void> _validatePhone(String phone, String emergencyPhone) async {
    bool isPrimaryValid = phone.length == 10;
    bool isEmergencyValid = emergencyPhone.length == 10;

    setState(() {
      _isValid = isPrimaryValid &&
          isEmergencyValid; // Update validity based on both numbers
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.register),
        actions: const [Info()],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 4 / 4,
            color: AppColors.baseColor,
            minHeight: Sizes.size8,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Sizes.size16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: Sizes.size12, bottom: Sizes.size16),
                        child: Text(
                          Strings.phone,
                          style: TextStyle(fontSize: Sizes.size32),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: Sizes.size12, bottom: Sizes.size32),
                        child: Text(
                          Strings.phoneDesc,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DropdownButton<String>(
                        value: dropdownValue,
                        onChanged: (String? value) {
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                        items: countryPhoneCodes
                            .map((Map<String, String> country) {
                          return DropdownMenuItem<String>(
                            value: country['code'],
                            child: Text(country['code']!),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        width: Sizes.size255,
                        child: TextField(
                          controller: _phoneController,
                          onChanged: (value) {
                            _validatePhone(
                                _phoneController.text,
                                _emergencyPhoneController
                                    .text); // Validate both phone numbers
                          },
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: Strings.phone,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // New input field for emergency contact number
                  SizedBox(height: Sizes.size16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DropdownButton<String>(
                        value: dropdownValue,
                        onChanged: (String? value) {
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                        items: countryPhoneCodes
                            .map((Map<String, String> country) {
                          return DropdownMenuItem<String>(
                            value: country['code'],
                            child: Text(country['code']!),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        width: Sizes.size255,
                        child: TextField(
                          controller: _emergencyPhoneController,
                          onChanged: (value) {
                            _validatePhone(
                                _phoneController.text,
                                _emergencyPhoneController
                                    .text); // Validate both phone numbers
                          },
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Emergency Contact Number',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: Sizes.size55),
                    child: AppButton(
                      title: Strings.next,
                      isValid: _isValid,
                      onTap: () {
                        // Set phone number to UserModel
                        Provider.of<UserModel>(context, listen: false)
                            .setPhone(dropdownValue + _phoneController.text);
                        // Set emergency contact number to UserModel
                        Provider.of<UserModel>(context, listen: false)
                            .setEmergencyContact(
                                dropdownValue + _emergencyPhoneController.text);
                        // Navigate to RegisterPin screen
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RegisterPin(),
                        ));
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
