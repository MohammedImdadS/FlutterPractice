import 'package:bloc_practice/bloc/bloc_actions.dart';
import 'package:bloc_practice/bloc/person.dart';
import 'package:bloc_practice/bloc/persons_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

const mockedPersons1 = [
  Person(
    age: 20,
    name: 'Foo',
  ),
  Person(
    age: 30,
    name: 'Bar',
  ),
];

const mockedPersons2 = [
  Person(
    age: 20,
    name: 'Foo',
  ),
  Person(
    age: 30,
    name: 'Bar',
  ),
];

Future<Iterable<Person>> mockGetPersons1(String _) =>
    Future.value(mockedPersons1);

Future<Iterable<Person>> mockGetPersons2(String _) =>
    Future.value(mockedPersons2);

void main() {
  group(
    'Testing bloc',
    () {
      // write our test

      late PersonBloc bloc;

      setUp(() {
        bloc = PersonBloc();
      });

      blocTest<PersonBloc, FetchResult?>(
        'Test initial state',
        build: () => bloc,
        verify: (bloc) => expect(bloc.state, null),
      );

      // fetch mock data (persons1) and compare it with FetchResult
      blocTest(
        'Mock retrieving person from first iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const LoadPersonsAction(
            url: 'dummy_url_1',
            loader: mockGetPersons1,
          ));
        },
      );
      blocTest(
        'Mock retrieving person from first iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const LoadPersonsAction(
            url: 'dummy_url_1',
            loader: mockGetPersons1,
          ));
        },
        expect: () => [
          const FetchResult(
            persons: mockedPersons1,
            isRetrievedFromCache: false,
          ),
          const FetchResult(
            persons: mockedPersons1,
            isRetrievedFromCache: true,
          ),
        ],
      );

      // fetch mock data (persons2) and compare it with FetchResult
      blocTest(
        'Mock retrieving person from second iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const LoadPersonsAction(
            url: 'dummy_url_2',
            loader: mockGetPersons2,
          ));
        },
      );
      blocTest(
        'Mock retrieving person from second iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const LoadPersonsAction(
            url: 'dummy_url_2',
            loader: mockGetPersons2,
          ));
        },
        expect: () => [
          const FetchResult(
            persons: mockedPersons2,
            isRetrievedFromCache: false,
          ),
          const FetchResult(
            persons: mockedPersons2,
            isRetrievedFromCache: true,
          ),
        ],
      );
    },
  );
}
