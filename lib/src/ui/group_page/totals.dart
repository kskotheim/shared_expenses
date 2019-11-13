import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/totals_bloc.dart';

class TotalsWidget extends StatelessWidget {
  TotalsBloc _totalsBloc;

  @override
  Widget build(BuildContext context) {
    GroupBloc groupBloc = BlocProvider.of<GroupBloc>(context);
    _totalsBloc = TotalsBloc(
        groupBloc: groupBloc, screenWidth: MediaQuery.of(context).size.width);
    return BlocProvider(
      bloc: _totalsBloc,
      child: StreamBuilder<ListOrBarGraphSelected>(
        stream: _totalsBloc.whichTotalsToShow,
        builder: (context, totalsFormSnapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SelectTotalsToShow(),
              (!totalsFormSnapshot.hasData ||
                      totalsFormSnapshot.data is TotalsListSelected)
                  ? TotalsList()
                  : TotalsGraph(),
            ],
          );
        },
      ),
    );
  }
}

class TotalsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TotalsBloc totalsBloc = BlocProvider.of<TotalsBloc>(context);

    return StreamBuilder<List<Widget>>(
      stream: totalsBloc.totalsList,
      builder: (context, totalsListTileSnapshot) {
        if (totalsListTileSnapshot.data == null) return Text('no totals data');
        return Expanded(
          child: ListView(
            shrinkWrap: true,
            children: totalsListTileSnapshot.data,
          ),
        );
      },
    );
  }
}

class TotalsGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TotalsBloc totalsBloc = BlocProvider.of<TotalsBloc>(context);
    return StreamBuilder<Column>(
      stream: totalsBloc.totalsBarGraph,
      builder: (context, totalsBarGraphSnapshot) {
        if (totalsBarGraphSnapshot.data == null) return Text('no totals data');
        return Expanded(
          child: totalsBarGraphSnapshot.data,
        );
      },
    );
  }
}

class SelectTotalsToShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TotalsBloc totalsBloc = BlocProvider.of<TotalsBloc>(context);

    return StreamBuilder<Object>(
      stream: totalsBloc.whichTotalsToShow,
      builder: (context, snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton(
              onPressed: totalsBloc.showTotalsList,
              color: snapshot.data is TotalsListSelected ? Colors.white : null,
              child: Text('List'),
            ),
            FlatButton(
              onPressed: totalsBloc.showTotalsGraph,
              color: snapshot.data is TotalsGraphSelected ? Colors.white : null,
              child: Text('Graph'),
            ),
          ],
        );
      },
    );
  }
}
