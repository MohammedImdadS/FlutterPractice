import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(MaterialApp(
    title: 'Home',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    home: BlocProvider(
      create: (_) => PersonBloc(),
      child: const HomeApp(),
    ),
  ));
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction implements LoadAction {
  final PersonUrl url;
  const LoadPersonsAction({required this.url}) : super();
}

enum PersonUrl {
  persons1,
  persons2,
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.persons1:
        return 'http://127.0.0.1:5500/api/persons1.json';
      case PersonUrl.persons2:
        return 'http://127.0.0.1:5500/api/persons2.json';
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
  @override
  String toString() => 'Person (name = $name , age = $age)';
}

Future<Iterable<Person>> getPerson(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });
  @override
  String toString() =>
      'FetchResult (isRetrievedFromCache = $isRetrievedFromCache, persons = $persons)';
}

class PersonBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  PersonBloc() : super(null) {
    on<LoadPersonsAction>((event, emit) async {
      final url = event.url;
      if (_cache.containsKey(url)) {
        // we have the value in the cache
        final cachePersons = _cache[url]!;
        final result = FetchResult(
          persons: cachePersons,
          isRetrievedFromCache: true,
        );
        emit(result);
      } else {
        final persons = await getPerson(url.urlString);
        _cache[url] = persons;
        final result = FetchResult(
          persons: persons,
          isRetrievedFromCache: false,
        );
        emit(result);
      }
    });
  }
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    context.read<PersonBloc>().add(
                          const LoadPersonsAction(url: PersonUrl.persons1),
                        );
                  },
                  child: const Text('Load json #1'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<PersonBloc>().add(
                          const LoadPersonsAction(url: PersonUrl.persons2),
                        );
                  },
                  child: const Text('Load json #2'),
                ),
              ],
            ),
            BlocBuilder<PersonBloc, FetchResult?>(
              buildWhen: (previousResult, currentResult) {
                return previousResult?.persons != currentResult?.persons;
              },
              builder: (context, fetchResult) {
                fetchResult?.log();
                final persons = fetchResult?.persons;
                if (persons == null) {
                  return const SizedBox();
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (context, index) {
                      final person = persons[index]!;
                      return ListTile(
                        title: Text(person.name),
                        
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ));
  }
}