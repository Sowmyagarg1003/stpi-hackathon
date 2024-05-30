import 'package:flutter/material.dart';

import '../utils/constants.dart';
import './scan_qr_page.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: Sizes.size89,
        leading: SizedBox(
          child: Image.asset(
            ImagePaths.companyIconColor,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/scanner_icon.png'),
            onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ScanQrPage()));},
          )
        ],
      ),
    );
  }
}
