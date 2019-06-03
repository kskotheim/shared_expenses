import 'package:flutter/material.dart';
import 'package:shared_expenses/src/root_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared Expenses',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: RootWidget(),
    );
  }
}
