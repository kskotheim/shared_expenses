import 'package:flutter/material.dart';
import 'package:shared_expenses/src/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appTitle = 'Shared Expenses';
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: appTitle),
    );
  }
}
