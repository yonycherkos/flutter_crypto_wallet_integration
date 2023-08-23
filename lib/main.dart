import 'package:flutter/material.dart';

import 'pages/metamask.dart';
// import 'pages/trust_wallet.dart';
import 'utils/routes.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: MyRoutes.metamaskUrl,
      routes: {
        MyRoutes.metamaskUrl: (context) => const MetaMask(),
        // MyRoutes.trustWalletUrl: (context) => const TrustWallet(),
      },
    );
  }
}
