import 'package:flutter/material.dart';

class AccountManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('this is the admin page'),
                Text('this is the admin page'),
                Text('this is the admin page'),
                Text('this is the admin page'),
                Text('this is the admin page'),
                Text('this is the admin page'),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
