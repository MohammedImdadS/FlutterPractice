import 'package:bloc_practice/bloc/person.dart';
import 'package:flutter/foundation.dart' show immutable;

const person1Url =
    'https://raw.githubusercontent.com/MohammedImdadS/FlutterPractice/main/StateManagement/bloc_practice/api/persons1.json';
const person2Url =
    'https://raw.githubusercontent.com/MohammedImdadS/FlutterPractice/main/StateManagement/bloc_practice/api/persons2.json';

typedef PersonLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction implements LoadAction {
  final String url;
  final PersonLoader loader;
  const LoadPersonsAction({
    required this.url,
    required this.loader,
  }) : super();
}
