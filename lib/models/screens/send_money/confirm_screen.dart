import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transactions_app/utils/constants.dart';
import 'package:transactions_app/widgets/app_button.dart';
import 'package:transactions_app/widgets/base_app_bar.dart';

import '../../services/auth_service.dart';

class ConfirmTransaction extends StatefulWidget {
  final String accountNo;
  final String? bankName;
  const ConfirmTransaction({Key? key, required this.accountNo, this.bankName})
      : super(key: key);

  @override
  State<ConfirmTransaction> createState() => _ConfirmTransactionState();
}

class QRDialog extends StatefulWidget {
  final Uint8List qrCodeImage;
  final VoidCallback onQRProcessed; // Add this callback

  const QRDialog(
      {Key? key, required this.qrCodeImage, required this.onQRProcessed})
      : super(key: key);

  @override
  _QRDialogState createState() => _QRDialogState();
}

class _QRDialogState extends State<QRDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isQRProcessed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true); // Start the animation
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color overlay
        Container(
          color: Colors.black45, // Adjust transparency as needed
        ),
        // Dialog content
        Center(
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(widget.qrCodeImage),
                SizedBox(height: 20), // Space between image and button
                ElevatedButton(
                  onPressed: () {
                    // Toggle the flag to indicate QR processing
                    setState(() {
                      _isQRProcessed = !_isQRProcessed;
                    });
                    print("Processing QR");

                    widget.onQRProcessed(); // Call the callback
                  },
                  child: Text('Process QR'),
                ),
              ],
            ),
          ),
        ),
        // Conditional hollow rectangle overlay
        if (_isQRProcessed)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: 5,
                left: 5,
                right: 5,
                bottom: 5,
                child: Opacity(
                  opacity:
                      0.5, // Set the opacity level (0.0 is fully transparent, 1.0 is fully opaque)
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Colors.white, width: 240), // Top width
                        bottom: BorderSide(
                            color: Colors.white, width: 240), // Bottom width
                        left: BorderSide(
                            color: Colors.white, width: 25), // Left width
                        right: BorderSide(
                            color: Colors.white, width: 25), // Right width
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, Widget? child) {
                        return LinearProgressIndicator(
                          value: _controller.value,
                          minHeight: 2, // Adjust the thickness of the line
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// The rest of your classes remain unchanged...

// The rest of your classes remain unchanged...

// The rest of your classes remain unchanged...

class _ConfirmTransactionState extends State<ConfirmTransaction> {
  bool _isQRProcessed = false;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _currentUserData;

  String amount = '';
  final _transferController = TextEditingController();
  bool _isSufficient = false;

  // checkbox
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _getUserData(widget.accountNo);
  }

  Future<void> _getUserData(accountNo) async {
    Object? snapshot = await AuthService().getUserDataByAccountNo(accountNo);
    final currentUserData = await AuthService().getCurrentUserData();

    setState(() {
      _userData = snapshot as Map<String, dynamic>?;
      _currentUserData = currentUserData;
    });
  }

  void assignValues() {
    setState(() {
      amount = _transferController.text;
      _checkBalance(amount);
    });
  }

  Future<void> _checkBalance(String amount) async {
    bool isSufficient = await AuthService().checkBalance(amount);

    setState(() {
      _isSufficient = isSufficient;
    });
  }

  // Define a new StatefulWidget for the dialog content

// Update the sendRequest function to use the new QRDialog StatefulWidget
  Future<void> sendRequest(String raccno, String saccno, String amount) async {
    final uri = Uri.http('192.168.1.14:3000', '/ciper', {
      'raccno': raccno,
      'saccno': saccno,
      'amount': amount,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        print('Request successful');
        showDialog(
          context: context,
          barrierDismissible:
              false, // Prevent closing the dialog with a tap outside
          builder: (_) => QRDialog(
            qrCodeImage: response.bodyBytes,
            onQRProcessed: _sendTransaction,
          ),
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Request failed with error: $e');
    }
  }

  Future<void> _sendTransaction() async {
    if (_currentUserData != null && _userData != null) {
      await AuthService().updateBalance(
        senderUserId: _currentUserData!['id'],
        receiverUserId: _userData!['id'],
        amount: amount,
      );

      if (isChecked) {
        await AuthService().addToQuickTransfer(_userData!['id']);
      }

      await AuthService().updateHistory('out', _userData!['id'], amount);

      Navigator.of(context).pushNamed('/success-send-money', arguments: amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: Strings.confirm, canPop: true),
      body: _userData == null
          ? Center(
              child: CircularProgressIndicator(
              color: AppColors.baseColor,
            ))
          : Padding(
              padding: EdgeInsets.only(
                  right: Sizes.size16, left: Sizes.size16, top: Sizes.size24),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person),
                      SizedBox(width: Sizes.size14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(bottom: Sizes.size8),
                              child: Text(
                                _userData!['username'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                          widget.bankName != null
                              ? Text(
                                  "${widget.bankName} - ${_userData!['account_no']}",
                                  style: const TextStyle(color: Colors.black54),
                                )
                              : Text(
                                  "Dragonfly Bank - ${_userData!['account_no']}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                        ],
                      ),
                    ],
                  ),
                  Wallet(currentUserData: _currentUserData),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      Strings.totalTranfer,
                      style: TextStyle(
                          fontSize: Sizes.size16, color: Colors.black87),
                    ),
                  ),
                  SizedBox(
                    height: Sizes.size16,
                  ),
                  TextField(
                    controller: _transferController,
                    onChanged: (value) => assignValues(),
                    style: TextStyle(
                        fontSize: Sizes.size24, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                        prefix: const Text('\$ '),
                        suffix: Text(Strings.usd),
                        border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: const UnderlineInputBorder()),
                  ),
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.only(top: Sizes.size20),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Add to quick transfer'),
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: Sizes.size40, top: Sizes.size32),
                    child: AppButton(
                      title: 'Scan QR',
                      isValid: true,
                      onTap: () {
                        sendRequest(_currentUserData!['account_no'],
                            _userData!['account_no'], amount);
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class ReceiverUser extends StatelessWidget {
  const ReceiverUser({
    super.key,
    required Map<String, dynamic>? userData,
    String? bankName,
  }) : _userData = userData;

  final Map<String, dynamic>? _userData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.person),
        SizedBox(width: Sizes.size14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.only(bottom: Sizes.size8),
                child: Text(
                  _userData!['username'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
            Text(
              " - ${_userData!['account_no']}",
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}

class Wallet extends StatelessWidget {
  const Wallet({
    super.key,
    required Map<String, dynamic>? currentUserData,
  }) : _currentUserData = currentUserData;

  final Map<String, dynamic>? _currentUserData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Sizes.size16, bottom: Sizes.size32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Sizes.size12),
            border: Border.all(
              color: AppColors.baseColor,
            )),
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Sizes.size20, vertical: Sizes.size16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.mainWallet,
                      style: TextStyle(
                          fontSize: Sizes.size10, color: Colors.black54),
                    ),
                    SizedBox(
                      height: Sizes.size10,
                    ),
                    Text(
                      '\$ ${_currentUserData!['total_balance']}',
                      style: TextStyle(
                          fontSize: Sizes.size16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.baseColor,
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
