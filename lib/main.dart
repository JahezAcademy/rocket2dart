import 'package:flutter/material.dart';
import 'package:json2dart/ui/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Json2Rocket [Flutter Rocket Package]',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
      ),
      home: MyHomePage(title: 'Json to Flutter Rocket Model'),
    );
  }
}
