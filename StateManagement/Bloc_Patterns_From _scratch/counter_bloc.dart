import 'dart:async';

import 'package:blocproject/counter_event.dart';

class CounterBloc {
  int _counter = 0;

  final _counterStateController = StreamController<int>();
  StreamSink<int> get _incrementCounter => _counterStateController.sink;

  Stream<int> get counter => _counterStateController.stream;

  final _counterEventController = StreamController<CounterEvent>();
  // for events, exposing only a sink which is an input
  Sink<CounterEvent> get counterEventSink => _counterEventController.sink;

  CounterBloc() {
    _counterEventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(CounterEvent event) {
    if (event is IncrementEvent) {
      _counter++;
      _incrementCounter.add(_counter);
    } else {
      _counter--;

      _incrementCounter.add(_counter);
    }
  }

  void dispose() {
    _counterStateController.close();
    _counterEventController.close();
  }
}

