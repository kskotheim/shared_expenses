import 'dart:async';
import 'package:shared_expenses/src/bloc/bloc_provider.dart';

class TotalsBloc implements BlocBase {

  StreamController<List<Total>> _totalsListController = StreamController<List<Total>>();
  Stream<List<Total>> get totalsList => _totalsListController.stream;

  TotalsBloc(){
    List<Total> list = [
      Total(name: 'Kris: \$5'),
      Total(name: 'Dre: \$10'),
      Total(name: 'Bob: -\$15'),
    ];
    _totalsListController.sink.add(list);
  }


  @override
  void dispose() {
    _totalsListController.close();
  }
}

class Total {
  final String name;
  Total({this.name});
}