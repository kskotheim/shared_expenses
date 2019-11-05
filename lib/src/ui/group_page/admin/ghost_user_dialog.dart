
import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/new_ghost_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/ui/group_page/admin/new_ghost_user_button.dart';

class GhostUserDialog extends StatelessWidget {
  final GroupBloc groupBloc;
  final NewGhostBloc ghostBloc;
  GhostUserDialog({this.groupBloc, this.ghostBloc})
      : assert(groupBloc != null, ghostBloc != null);

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      bloc: ghostBloc,
      child: Dialog(
        child: Container(
          padding: Style.eventsViewPadding,
          height: 300.0,
          width: 200.0,
          child: Column(
            children: <Widget>[
              Text(
                'Ghost Users',
                style: Style.subTitleTextStyle,
              ),
              StreamBuilder<List<Widget>>(
                stream: ghostBloc.ghostWidgets,
                builder: (context, snapshot) {
                  if(!snapshot.hasData) return CircularProgressIndicator();

                  return Container(
                    height: 190.0,
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.data,
                    ),
                  );
                }
              ),
              Divider(),
              NewGhostUserButton(groupBloc: groupBloc),
            ],
          ),
        ),
      ),
    );
  }
}