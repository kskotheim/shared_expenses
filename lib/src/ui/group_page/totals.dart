import 'package:flutter/material.dart';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';
import 'package:shared_expenses/src/bloc/group_bloc.dart';
import 'package:shared_expenses/src/bloc/totals_bloc.dart';
import 'package:shared_expenses/src/res/style.dart';

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
              Container(height: 5.0),
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
          child: SingleChildScrollView(
            child: Column(children: totalsListTileSnapshot.data),
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
          child: SingleChildScrollView(child: totalsBarGraphSnapshot.data),
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
            InkWell(
              onTap: totalsBloc.showTotalsList,
              child: Container(
                width: MediaQuery.of(context).size.width * .5,
                height: 30.0,
                child: Center(
                    child: Text(
                  'List',
                  style: snapshot.data is TotalsListSelected ? Style.regularTextStyle : Style.regularTextStyleFaded,
                )),
                color: !(snapshot.data is TotalsListSelected)
                    ? Colors.white70
                    : null,
              ),
            ),
            InkWell(
              onTap: totalsBloc.showTotalsGraph,
              child: Container(
                color: !(snapshot.data is TotalsGraphSelected)
                    ? Colors.white70
                    : null,
                width: MediaQuery.of(context).size.width * .5,
                height: 30.0,
                child: Center(
                    child: Text(
                  'Graph',
                  style: snapshot.data is TotalsGraphSelected ? Style.regularTextStyle : Style.regularTextStyleFaded,
                )),
              ),
            ),
          ],
        );
      },
    );
  }
}
