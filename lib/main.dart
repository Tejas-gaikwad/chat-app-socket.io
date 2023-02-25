import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_appliaction/Provider/homeScreen.provider.dart';
import 'package:webcrypto/webcrypto.dart';

import 'nameScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _generateKeys() async {
    //1. Generate keys
    KeyPair<EcdhPrivateKey, EcdhPublicKey> keyPair =
        await EcdhPrivateKey.generateKey(EllipticCurve.p256);
    Map<String, dynamic> publicKeyJwk =
        await keyPair.publicKey.exportJsonWebKey();
    Map<String, dynamic> privateKeyJwk =
        await keyPair.privateKey.exportJsonWebKey();

    print("PUBLIC KEY --- " + publicKeyJwk.toString());
    print("PRIVATE KEY --- " + privateKeyJwk.toString());
  }

  @override
  void initState() {
    super.initState();
    _generateKeys();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeScreenProvider>(
          create: (_) => HomeScreenProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: NameScreen(),
      ),
    );
  }
}
