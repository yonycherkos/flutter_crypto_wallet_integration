// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slider_button/slider_button.dart';

import '../utils/helperfunctions.dart';

class MetaMask extends StatefulWidget {
  const MetaMask({Key? key}) : super(key: key);

  @override
  State<MetaMask> createState() => _MetaMaskState();
}

class _MetaMaskState extends State<MetaMask> {
  var connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'My App',
      description: 'An app for converting pictures to NFT',
      url: 'https://walletconnect.org',
      icons: [
        'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
      ],
    ),
  );

  var _session, _uri, _signature;

  loginUsingMetamask(BuildContext context) async {
    if (!connector.connected) {
      try {
        var session = await connector.createSession(
          onDisplayUri: (uri) async {
            _uri = uri;
            await launchUrlString(uri, mode: LaunchMode.externalApplication);
          },
        );
        print('account_id: ${session.accounts[0]}');
        print('chain_id: ${session.chainId}');
        print('uri: $_uri');
        setState(() => _session = session);
      } catch (exp) {
        print(exp);
      }
    }
  }

  signMessageWithMetamask(BuildContext context, String message) async {
    if (connector.connected) {
      try {
        print("Message received");
        print(message);

        EthereumWalletConnectProvider provider =
            EthereumWalletConnectProvider(connector);
        launchUrlString(_uri, mode: LaunchMode.externalApplication);
        var signature = await provider.personalSign(
          message: message,
          address: _session.accounts[0],
          password: "",
        );
        print(signature);
        setState(() {
          _signature = signature;
        });
      } catch (exp) {
        print("Error while signing transaction");
        print(exp);
      }
    }
  }

  getNetworkName(chainId) {
    print('chainId: $chainId');
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goreli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 137:
        return 'Polygon Mainnet';
      case 80001:
        return 'Mumbai Testnet';
      default:
        return 'Unknown Chain';
    }
  }

  @override
  Widget build(BuildContext context) {
    connector.on('connect', (session) => setState(() => _session = _session));
    connector.on(
      'session_update',
      (payload) => setState(() {
        _session = payload;
        print(_session.accounts[0]);
        print(_session.chainId);
      }),
    );
    connector.on('disconnect', (payload) => setState(() => _session = null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('MetaMask'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/main_page_image.png',
              fit: BoxFit.fitHeight,
            ),
            (_session != null)
                ? Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: GoogleFonts.merriweather(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${_session.accounts[0]}',
                          style: GoogleFonts.inconsolata(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Chain: ',
                              style: GoogleFonts.merriweather(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              getNetworkName(_session.chainId),
                              style: GoogleFonts.inconsolata(fontSize: 16),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        (_session.chainId != 56)
                            ? const Row(
                                children: [
                                  Icon(Icons.warning,
                                      color: Colors.redAccent, size: 15),
                                  Text('Network not supported. Switch to '),
                                  Text(
                                    'Ethereum Mainnet',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                            : (_signature == null)
                                ? Container(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                        onPressed: () =>
                                            signMessageWithMetamask(
                                                context,
                                                generateSessionMessage(
                                                    _session.accounts[0])),
                                        child: const Text('Sign Message')),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Signature: ",
                                            style: GoogleFonts.merriweather(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Text(
                                              truncateString(
                                                  _signature.toString(), 4, 2),
                                              style: GoogleFonts.inconsolata(
                                                  fontSize: 16))
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      SliderButton(
                                        action: () async {
                                          // TODO: Navigate to main page
                                        },
                                        label: const Text('Slide to login'),
                                        icon: const Icon(Icons.check),
                                      )
                                    ],
                                  )
                      ],
                    ))
                : ElevatedButton(
                    onPressed: () => loginUsingMetamask(context),
                    child: const Text("Connect with Metamask"))
          ],
        ),
      ),
    );
  }
}