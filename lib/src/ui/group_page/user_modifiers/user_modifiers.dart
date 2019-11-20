import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/user_modifier_bloc.dart';
import 'package:shared_expenses/src/res/models/user.dart';
import 'package:shared_expenses/src/res/style.dart';
import 'package:shared_expenses/src/res/util.dart';
import 'package:shared_expenses/src/ui/group_page/user_modifiers/new_modifier_button.dart';

class UserModifierList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
    UserModifierBloc userModifierBloc = UserModifierBloc(groupBloc: groupBloc);

    return BlocProvider(
      bloc: userModifierBloc,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'User Modifiers for ${groupBloc.currentGroup.accountName}',
              style: Style.subTitleTextStyle,
            ),
            StreamBuilder<List<UserModifier>>(
              stream: userModifierBloc.userModifierStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                if (snapshot.data.length == 0) return Text('No Modifiers');

                return ListView(
                  shrinkWrap: true,
                  children: snapshot.data.map((modifier) {
                    String title = groupBloc.userName(modifier.userId) +
                        ': ' +
                        modifier.shares.toString() +
                        ' shares';
                    if (modifier.fromDate != null)
                      title += ' from ${parseDateTime(modifier.fromDate)}';
                    if (modifier.toDate != null)
                      title += ' to ${parseDateTime(modifier.toDate)}';
                    if (modifier.categories != null) {
                      title += ' categories: ';
                      modifier.categories
                          .forEach((category) => title += ' $category');
                    }
                    return ListTile(
                      title: Text(title),
                      trailing: IconButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                                'Are you sure you want to delete this modifier?'),
                            content: Text(
                                'This action will be visible to members of the group'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              DeleteModifierDialogButton(modifier: modifier,groupBloc: groupBloc,),
                            ],
                          ),
                        ),

                        // ,
                        icon: Icon(Icons.delete),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            NewModifierButton()
          ],
        ),
      ),
    );
  }
}

class DeleteModifierDialogButton extends StatefulWidget {
  final UserModifier modifier;
  final GroupBloc groupBloc;

  DeleteModifierDialogButton({this.modifier, this.groupBloc}) : assert(modifier != null), assert(groupBloc != null);
  @override
  _DeleteModifierDialogButtonState createState() =>
      _DeleteModifierDialogButtonState();
}

class _DeleteModifierDialogButtonState
    extends State<DeleteModifierDialogButton> {
  bool deleting = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(deleting ? 'Deleting ...' : 'Delete'),
      onPressed: !deleting ? () async {
        setState(() => deleting = true);
        await widget.groupBloc.deleteModifier(widget.modifier);
        widget.groupBloc.tabulateTotals();
        return Navigator.of(context).pop();
      } : null,
    );
  }
}
