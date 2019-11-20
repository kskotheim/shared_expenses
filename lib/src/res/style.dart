

import 'package:flutter/material.dart';

class Style {

  static const TextStyle titleTextStyle = const TextStyle(fontSize: 32.0, fontFamily: 'Modak');
  
  static const TextStyle subTitleTextStyle = const TextStyle(fontSize: 22.0, fontFamily: 'Ubuntu');
  static const TextStyle boldSubTitleStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700, fontFamily: 'Ubuntu');
  static const TextStyle subTitleTextStyleWhite = const TextStyle(fontSize: 22.0, color: Colors.white, fontFamily: 'Ubuntu');
  
  static const TextStyle regularTextStyle = const TextStyle(fontSize: 16.0, fontFamily: 'Ubuntu');
  static const TextStyle regularTextStyleRed = const TextStyle(fontSize: 16.0, fontFamily: 'Ubuntu', color: Colors.red);
  static const TextStyle regularTextStyleGreen = const TextStyle(fontSize: 16.0, fontFamily: 'Ubuntu', color: Colors.green);
  static const TextStyle regularTextStyleBlue = const TextStyle(fontSize: 16.0, fontFamily: 'Ubuntu', color: Colors.blue);
  static const TextStyle regularTextStyleFaded = const TextStyle(fontSize: 16.0, fontFamily: 'Ubuntu', color: fadedTextColor);

  static const TextStyle tinyTextStyle = const TextStyle(fontSize: 12.0, fontFamily: 'Ubuntu');
  static const TextStyle tinyTextStyleFaded = const TextStyle(fontSize: 12.0, fontFamily: 'Ubuntu', color: fadedTextColor);
  static const TextStyle tinyTextStyleWhite = const TextStyle(fontSize: 12.0, color: Colors.white, fontFamily: 'Ubuntu');

  static const EdgeInsets floatingActionPadding = const EdgeInsets.fromLTRB(9.0, 9.0, 9.0, 9.0);
  static const EdgeInsets eventsViewPadding = const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0);
  static const EdgeInsets gridItemPadding = const EdgeInsets.all(2.0);

  static BoxDecoration selectAccountDecoration(bool isOwner) => BoxDecoration(border: Border.all(color: isOwner ? gold : darkBrown, width: isOwner ? 3 : 1), borderRadius: BorderRadius.all(Radius.circular(12.0)), gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [lightGreen, darkGreen]));
  static final BoxDecoration selectAccountDecorationOwner = BoxDecoration(border: Border.all(color: darkBrown), borderRadius: BorderRadius.all(Radius.circular(12.0)), gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [lightGreen, lightBrown]));
  static final BoxDecoration editDeleteDecoration = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)), border: Border.all(color: darkBrown), gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.redAccent, Colors.orangeAccent]));
  static final BoxDecoration editDeleteDecorationReverse = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)), border: Border.all(color: darkBrown), gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.orangeAccent, Colors.redAccent]));

  static final BoxDecoration redFadeBoxDecoration = BoxDecoration(borderRadius: BorderRadius.circular(5.0), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.red.shade100, Colors.red.shade300]));
  static final BoxDecoration greenFadeBoxDecoration = BoxDecoration(borderRadius: BorderRadius.circular(5.0), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.green.shade100, Colors.green.shade300]));

  static const Color darkBrown = const Color(0xff3e3e3c);
  static const Color lightBrown = const Color(0xffe8e9c9);
  static const Color darkGreen = const Color(0xff228d57);
  static const Color lightGreen = const Color(0xff85bb65);
  static const Color fadedTextColor = const Color(0x80808080);
  static const Color gold = const Color(0xffd4af37);
  
  static final ShapeBorder roundedButtonBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0));

}