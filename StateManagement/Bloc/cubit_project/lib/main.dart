import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'dart:math' as math show Random;

void main() {
  runApp(MaterialApp(
    title: 'Home',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    home: const HomeApp(),
  ));
}

const words = [
  'Mango',
  'FootBall',
  'Car',
  'Store'
];

extension RandomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(math.Random().nextInt(length));
}

class RandomWordCubit extends Cubit<String?> {
  RandomWordCubit() : super(null);

  void pickRandomWord() {
    emit(words.getRandomElement());
  }
}

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  late final RandomWordCubit cubit;
  @override
  void initState() {
    cubit = RandomWordCubit();
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: StreamBuilder(
        stream: cubit.stream,
        builder: (context, snapshot) {
          final button = TextButton(
            onPressed: () => cubit.pickRandomWord(),
            child: const Text('Pick a random word'),
          );
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return button;
            case ConnectionState.waiting:
              return button;
            case ConnectionState.active:
              return Column(
                children: [
                  Text(snapshot.data ?? ''),
                  button,
                ],
              );
            case ConnectionState.done:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
