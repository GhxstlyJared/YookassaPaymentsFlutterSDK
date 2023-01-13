import 'package:flutter/material.dart';
import 'tokenization_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Example app",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TokenizationScreen(),
    );
  }
}
