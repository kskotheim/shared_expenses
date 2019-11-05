import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_ghost_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';

class NewGhostUserButton extends StatefulWidget {
  final GroupBloc groupBloc;

  NewGhostUserButton({this.groupBloc}) : assert(groupBloc != null);

  @override
  _NewGhostUserButtonState createState() => _NewGhostUserButtonState();
}

class _NewGhostUserButtonState extends State<NewGhostUserButton> {
  bool enteringNewUser = false;

  @override
  Widget build(BuildContext context) {
    NewGhostBloc ghostBloc = BlocProvider.of<NewGhostBloc>(context);

    if (!enteringNewUser) {
      return IconButton(
        icon: Icon(Icons.add),
        onPressed: () => setState(() => enteringNewUser = true),
      );
    } else {
      return Row(
        children: <Widget>[
          IconButton(
            onPressed: () => setState(() => enteringNewUser = false),
            icon: Icon(Icons.cancel),
          ),
          StreamBuilder<String>(
              stream: ghostBloc.ghostName,
              builder: (context, snapshot) {
                return Container(
                  width: 100.0,
                  child: TextField(
                    onChanged: ghostBloc.newGhostName,
                    style: Style.regularTextStyle,
                    decoration: InputDecoration(errorText: snapshot.error),
                  ),
                );
              }),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () => ghostBloc.submitGhost().then((_) => setState(() => enteringNewUser = false)),
          )
        ],
      );
    }
  }
}
