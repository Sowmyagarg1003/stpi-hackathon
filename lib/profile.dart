import 'package:flutter/material.dart';
import 'package:transactions_app/models/screens/login_screen.dart';
import 'package:transactions_app/models/services/auth_service.dart';

import 'package:transactions_app/widgets/base_app_bar.dart';

import 'utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const BaseAppBar(title: 'Profile', canPop: false),
        body: _userData != null
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(Sizes.size16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: Sizes.size40),
                      CircleAvatar(
                        radius: Sizes.size40,
                        backgroundImage: NetworkImage(
                            'https://www.gravatar.com/avatar/${_userData!['email']}?d=identicon'),
                      ),
                      SizedBox(height: Sizes.size20),
                      Text(
                        _userData!['username'],
                        style: TextStyle(
                          fontSize: Sizes.size20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: Sizes.size10),
                      Text(
                        'Account Number: ${_userData!['account_no']}',
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: Sizes.size10),
                      Text(
                        'Phone Number: ${_userData!['phone']}',
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: Sizes.size10),
                      Text(
                        'Email Id: ${_userData!['email']}',
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: Sizes.size10),
                      Text(
                        'Your Balance: ${_userData!['total_balance']}',
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: Sizes.size40),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: Sizes.size12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Sizes.size8),
                          ),
                        ),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  color: AppColors.baseColor,
                ),
              ));
  }
}
