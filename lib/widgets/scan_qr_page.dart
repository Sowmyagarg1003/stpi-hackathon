import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrPage extends StatefulWidget {
  @override
  _ScanQrPageState createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // Handle QR code scan result
      final transactionId = scanData.code;
      await _processQrCode(transactionId!);
      controller.pauseCamera();
      Navigator.pop(context); // Go back to the previous screen after processing
    });
  }

  Future<void> _processQrCode(String transactionId) async {
    print(transactionId);
    // final response = await http.post(
    //   Uri.parse('http://localhost:3000/process-qr'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode({'transactionId': transactionId}),
    // );

    // if (response.statusCode == 200) {
    //   // Handle success
    //   print('Transaction successful');
    // } else {
    //   // Handle error
    //   print('Failed to process transaction');
    // }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
