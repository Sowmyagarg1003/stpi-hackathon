import 'package:flutter/material.dart';
import 'package:transactions_app/utils/constants.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: IconButton(
      onPressed: () => print('info button'),
      icon: const Icon(Icons.info_outline),
      iconSize: Sizes.size30,
    ));
  }
}
