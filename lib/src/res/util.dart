import 'package:flutter/material.dart';
import 'package:shared_expenses/src/res/style.dart';

String parseDateTime(DateTime time) {
  if (time == null) return null;
  return '${time.month}/${time.day}/${time.year % 2000}';
}

String getMonthString(int month) {
  switch (month) {
    case 1:
      return 'Jan';
      break;
    case 2:
      return 'Feb';
      break;
    case 3:
      return 'Mar';
      break;
    case 4:
      return 'Apr';
      break;
    case 5:
      return 'May';
      break;
    case 6:
      return 'Jun';
      break;
    case 7:
      return 'Jul';
      break;
    case 8:
      return 'Aug';
      break;
    case 9:
      return 'Sep';
      break;
    case 10:
      return 'Oct';
      break;
    case 11:
      return 'Nov';
      break;
    case 12:
      return 'Dec';
      break;
    default:
      return 'Err';
  }
}

class DateIcon extends StatelessWidget {
  final int month;
  final int day;
  final Color color;
  BoxBorder border;

  DateIcon(this.month, this.day, [this.color, this.border]);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: color,
        border: border,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('$day', style: Style.subTitleTextStyle),
          Text(
            '${getMonthString(month)}',
            style: Style.tinyTextStyle,
          ),
        ],
      ),
    );
  }
}

Future<DateTime> pickDate(BuildContext context) {
  return showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.parse("20000101"),
    lastDate: DateTime.parse("21001231"),
  );
}

class LinearLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconImage30Pct(),
          LinearProgressIndicator(),
        ],
      ),
    );
  }
}

class CircularLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconImage30Pct(),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class IconImage30Pct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('assets/icon.png'),
      height: MediaQuery.of(context).size.height * .3,
      width: MediaQuery.of(context).size.height * .3,
    );
  }
}
