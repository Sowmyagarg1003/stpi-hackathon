import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/src/intl/date_format.dart';

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection("users");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp(BuildContext context,
      {required String username,
      required String email,
      required String password,
      required String phone,
      required String emergencyContact,
      required String pin}) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await registerUser(
            user: userCredential,
            id: userCredential.user!.uid,
            username: username,
            email: email,
            password: password,
            phone: phone,
            emergencyContact: emergencyContact,
            pin: pin);
        navigator.pushNamed('/home', arguments: userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> signIn(BuildContext context,
      {required String email,
      required String username,
      required String password}) async {
    final navigator = Navigator.of(context);
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      final UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
              email: _isEmail(email) ? email : snapshot.docs.first['email'],
              password: password);
      if (userCredential.user != null) {
        print(userCredential.user!.uid);
        final userDoc = await userCollection
            .doc(userCredential.user!.uid)
            .get()
            .then((value) => value.data());

        navigator.pushNamed('/home',
            arguments: await getUserData(userCredential.user!.uid));
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }
  }

  Future<Object?> getUserData(String uid) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return snapshot.data();
  }

  Future<void> registerUser(
      {required UserCredential user,
      required String id,
      required String username,
      required String email,
      required String password,
      required String emergencyContact,
      required String phone,
      required String pin}) async {
    await userCollection.doc(user.user!.uid).set({
      "account_no": generateRandomNumber(),
      "cards": [],
      "email": email,
      "history": [],
      "id": id,
      "password": password,
      "emergencyContact": emergencyContact,
      "phone": phone,
      "quick_transfer": [],
      "total_balance": 0,
      "username": username,
      "pin": pin,
      "reversedPin": reversePin(pin),
    });
  }

  String reversePin(String pin) {
    return pin.split('').reversed.join();
  }

  Future<DocumentReference<Map<String, dynamic>>> getCurrentUser() async {
    String currentUserId = firebaseAuth.currentUser!.uid;
    final user = userCollection.doc(currentUserId);

    return user;
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    String currentUserId = firebaseAuth.currentUser!.uid;
    final user = await userCollection.doc(currentUserId).get();

    return user.data();
  }

  Future<Object?> getUserDataByAccountNo(String accountNo) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('account_no', isEqualTo: accountNo)
        .limit(1)
        .get();
    Object? data = snapshot.docs.first.data();
    return data;
  }

  Future<void> updateBalance(
      {required String senderUserId,
      required String receiverUserId,
      required String amount}) async {
    final sender = userCollection.doc(senderUserId);
    final receiver = userCollection.doc(receiverUserId);

    final senderSnapshot = await sender.get();
    final receiverSnapshot = await receiver.get();

    num senderBalance = senderSnapshot.data()!['total_balance'];
    num receiverBalance = receiverSnapshot.data()!['total_balance'];

    // Convert amount to a numeric value
    num transferAmount = num.parse(amount);

    // Check if the sender has enough balance to make the transfer
    if (senderBalance >= transferAmount) {
      // Deduct the amount from the sender's balance
      senderBalance -= transferAmount;

      // Add the amount to the receiver's balance
      receiverBalance += transferAmount;

      // Ensure that the sender's balance does not become negative
      if (senderBalance >= 0) {
        // Update the balances in the database
        await sender.update({"total_balance": senderBalance});
        await receiver.update({"total_balance": receiverBalance});

        print("Balance updated");
      } else {
        // Log an error message if the sender's balance becomes negative
        print("Error: Sender's balance cannot be negative");
      }
    } else {
      // Log an error message if the sender does not have enough balance
      print("Error: Insufficient balance");
    }
  }

  Future<void> addToQuickTransfer(String userId) async {
    String currentUserId = firebaseAuth.currentUser!.uid;
    final user = userCollection.doc(currentUserId);

    final userSnapshot = await user.get();
    List<dynamic> currentList = userSnapshot.data()?['quick_transfer'] ?? [];

    if (!currentList.contains(userId)) {
      currentList.add(userId);
      user.update({'quick_transfer': currentList});
      print("user $userId added to quick transfer list");
    }
  }

  Future<List<Map<String, dynamic>>> getQuickTransferList() async {
    String currentUserId = firebaseAuth.currentUser!.uid;
    final user = userCollection.doc(currentUserId);

    final userSnapshot = await user.get();

    List<dynamic> transferList = userSnapshot.data()?['quick_transfer'] ?? [];

    List<Map<String, dynamic>> userLlist = [];

    for (var id in transferList) {
      var userToAdd = await getUserData(id) as Map<String, dynamic>;

      userLlist.add(userToAdd);
    }

    return userLlist;
  }

  Future<void> updateHistory(
      String transactionType, String otherUserId, String amount) async {
    String currentUserId = firebaseAuth.currentUser!.uid;

    final currentUser = await getCurrentUser();
    final currentUserSnapshot = await getCurrentUserData();

    final otherUser = userCollection.doc(otherUserId);
    final otherUserSnapshot = await otherUser.get();

    List<dynamic> currentUserHistory = currentUserSnapshot!['history'];
    List<dynamic> otherUserHistory = otherUserSnapshot.data()!['history'];

    if (transactionType == 'out') {
      currentUserHistory.add({
        'amount': num.tryParse(amount),
        'date': DateTime.now(),
        'transaction_type': transactionType,
        'user_id': otherUserId,
        'username': otherUserSnapshot.data()!['username'],
      });

      otherUserHistory.add({
        'amount': num.tryParse(amount),
        'date': DateTime.now(),
        'transaction_type': 'in',
        'user_id': currentUserId,
        'username': currentUserSnapshot['username']
      });
    } else {
      currentUserHistory.add({
        'amount': num.tryParse(amount),
        'date': DateTime.now(),
        'transaction_type': 'in',
        'user_id': otherUserId,
        'username': otherUserSnapshot.data()!['username']
      });

      otherUserHistory.add({
        'amount': num.tryParse(amount),
        'date': DateTime.now(),
        'transaction_type': transactionType,
        'user_id': currentUserId,
        'username': currentUserSnapshot['username'],
      });
    }

    currentUser.update({'history': currentUserHistory});
    otherUser.update({'history': otherUserHistory});
  }

  Future<List<dynamic>> getHistory() async {
    String currentUserId = firebaseAuth.currentUser!.uid;
    final currentUserSnapshot = await userCollection.doc(currentUserId).get();

    List<dynamic> history = currentUserSnapshot.data()?['history'] ?? [];

    for (var el in history) {
      DateTime dt = (el['date'] as Timestamp).toDate();

      el['date'] = DateFormat.MMMd().format(dt);
    }

    return history.reversed.toList();
  }

  Future<num> getIncome() async {
    // String currentUserId = firebaseAuth.currentUser!.uid;
    // final currentUser = userCollection.doc(currentUserId);
    // final currentUserSnapshot = await currentUser.get();

    final currentUser = await getCurrentUser();
    final currentUserSnapshot = await getCurrentUserData();

    List<dynamic> currentUserHistory = currentUserSnapshot!['history'] ?? [];

    num totalIn = 0;

    for (var el in currentUserHistory) {
      if (el['transaction_type'] == 'in') {
        totalIn += el['amount'];
      }
    }

    return totalIn;
  }

  Future<num> getSpending() async {
    // String currentUserId = firebaseAuth.currentUser!.uid;
    // final currentUser = userCollection.doc(currentUserId);
    // final currentUserSnapshot = await currentUser.get();

    final currentUser = await getCurrentUser();
    final currentUserSnapshot = await getCurrentUserData();

    List<dynamic> currentUserHistory = currentUserSnapshot!['history'] ?? [];

    num totalSpending = 0;

    for (var el in currentUserHistory) {
      if (el['transaction_type'] == 'out') {
        totalSpending += el['amount'];
      }
    }
    return totalSpending;
  }

  Future<List> getTransactionHistoryByDate(
      String startDate, String endDate) async {
    final currentUser = await getCurrentUser();
    final currentUserSnapshot = await getCurrentUserData();

    List<dynamic> currentUserHistory = currentUserSnapshot!['history'] ?? [];

    List transactionList = [];

    for (var el in currentUserHistory) {
      DateTime historyDate =
          DateTime.parse((el['date'] as Timestamp).toDate().toString());
      if (historyDate.isAfter(DateTime.parse(startDate)) &&
          historyDate.isBefore(DateTime.parse(endDate))) {
        transactionList.add(el);
      }
      DateTime dt = (el['date'] as Timestamp).toDate();

      el['date'] = DateFormat.MMMd().format(dt);
    }

    return transactionList.reversed.toList();
  }

  Future<void> addCard(String background, String target, String balanceType,
      String cardNo) async {
    final currentUser = await getCurrentUser();
    final currentUserSnapshot = await getCurrentUserData();

    List cardList = currentUserSnapshot?['cards'] ?? [];

    cardList.add({
      'background': background,
      'balance': 0,
      'balance_type': balanceType,
      'card_no': generateCardNo(),
      'target': num.parse(target)
    });

    print(cardList);

    await currentUser.update({'cards': cardList});
  }

  Future<void> updateCardDeposit(String amount, String cardNo) async {
    final currentUser = await getCurrentUser();
    final currentUserSnapshot = await getCurrentUserData();

    List cardList = currentUserSnapshot?['cards'] ?? [];

    for (var el in cardList) {
      if (el['card_no'] == cardNo) {
        el['balance'] += num.parse(amount);
      }
    }
    num totalBalance = currentUserSnapshot!['total_balance'];
    totalBalance -= num.parse(amount);

    await currentUser.update({'total_balance': totalBalance});
    await currentUser.update({'cards': cardList});
  }

  Future<void> updateCardWithdraw(String amount, String cardNo) async {
    final currentUser = await getCurrentUser();
    final currentUserSnapshot = await getCurrentUserData();

    List cardList = currentUserSnapshot?['cards'] ?? [];

    for (var el in cardList) {
      if (el['card_no'] == cardNo) {
        el['balance'] -= num.parse(amount);
      }
    }

    num totalBalance = currentUserSnapshot!['total_balance'];
    totalBalance += num.parse(amount);

    await currentUser.update({'total_balance': totalBalance});
    await currentUser.update({'cards': cardList});
  }

  Future<void> editCard(String pocketName, String target, String cardNo) async {
    final currentUser = await getCurrentUser();
    final currentUserSnapshot = await getCurrentUserData();

    List cardList = currentUserSnapshot?['cards'] ?? [];

    for (var el in cardList) {
      if (el['card_no'] == cardNo) {
        el['balance_type'] = pocketName;
        el['target'] = num.parse(target);
      }
    }

    await currentUser.update({'cards': cardList});
  }

  String generateCardNo() {
    final random = Random();
    String cardNo = '';

    for (int i = 0; i < 16; i++) {
      cardNo += random.nextInt(10).toString();
    }

    return cardNo;
  }

  Future<bool> checkAccount(String accountNo) async {
    QuerySnapshot query =
        await userCollection.where('account_no', isEqualTo: accountNo).get();

    return query.docs.isEmpty ? false : true;
  }

  Future<bool> checkBalance(String amount) async {
    amount = amount == '' ? '0' : amount;
    final currentUserData = await getCurrentUserData();

    final balance = currentUserData!['total_balance'];

    return num.parse(amount) < balance;
  }

  bool _isEmail(String email) {
    bool isValid = EmailValidator.validate(email);
    return isValid;
  }

  Future<bool> checkEmail(String email) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return query.docs.isEmpty ? true : false;
  }

  Future<bool> checkUsername(String username) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return query.docs.isEmpty ? true : false;
  }

  Future<bool> checkPhone(String phone) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    return query.docs.isEmpty ? true : false;
  }

  String generateRandomNumber() {
    Random random = Random();
    int min = 100000000;
    int max = 999999999;
    return (min + random.nextInt(max - min + 1)).toString();
  }

  Future<String?> getUserPin() async {
    try {
      // Get the current user's UID
      String currentUserId = firebaseAuth.currentUser!.uid;

      // Get the user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await userCollection.doc(currentUserId).get();

      // Extract the user's PIN from the document data
      String? pin = userDoc.data()?['pin'];

      return pin;
    } catch (e) {
      print("Error getting user's PIN: $e");
      return null;
    }
  }

  Future<bool> validatePin(String pin) async {
    try {
      // Get the current user's UID
      String currentUserId = firebaseAuth.currentUser!.uid;

      // Get the user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await userCollection.doc(currentUserId).get();

      // Extract the user's PIN from the document data
      String? storedPin = userDoc.data()?['pin'];

      // Compare the entered pin with the stored pin
      return pin == storedPin;
    } catch (e) {
      print("Error validating pin: $e");
      return false;
    }
  }
}
