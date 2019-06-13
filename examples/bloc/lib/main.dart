// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';

class BlocSum {
  BlocSum() {
    count = Observable.combineLatest2(
      _countA.distinct().flatMap((s) => s),
      _countB.distinct().flatMap((s) => s),
      (int a, int b) => a + b,
    );
  }

  Stream<int> count;

  // There's no guarantee that the stream instanc will never change
  // therefore it is represented as a setter instead of an immutable variable.
  //
  // We could take the assumption that the instance never changes
  // to reduce the boilerplate. But that makes the BLoC less resilient.

  final _countA = BehaviorSubject<Stream<int>>();

  set countA(Stream<int> value) => _countA.add(value);

  final _countB = BehaviorSubject<Stream<int>>();

  set countB(Stream<int> value) => _countB.add(value);

  void dispose() {
    _countA.close();
    _countB.close();
  }
}

class BlocA {
  final BehaviorSubject<int> count = BehaviorSubject<int>.seeded(0);

  void increment() => count.add(count.value + 1);

  void dispose() {
    count.close();
  }
}

class BlocB {
  final BehaviorSubject<int> count = BehaviorSubject<int>.seeded(0);

  void increment() => count.add(count.value + 1);

  void dispose() {
    count.close();
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BlocA>(
          builder: (_) => BlocA(),
          dispose: (_, bloc) => bloc.dispose(),
        ),
        Provider<BlocB>(
          builder: (_) => BlocB(),
          dispose: (_, bloc) => bloc.dispose(),
        ),
        ProxyProvider2<BlocA, BlocB, BlocSum>(
          initialBuilder: (_) => BlocSum(),
          builder: (_, a, b, bloc) => bloc
            ..countA = a.count
            ..countB = b.count,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the top button this many times:'),
            StreamBuilder<int>(
              stream: Provider.of<BlocA>(context).count,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data}',
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
            const Text('You have pushed the bottom button this many times:'),
            StreamBuilder<int>(
              stream: Provider.of<BlocB>(context).count,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data}',
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
            const Text('Total:'),
            StreamBuilder<int>(
              stream: Provider.of<BlocSum>(context).count,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data}',
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            onPressed: Provider.of<BlocA>(context).increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: Provider.of<BlocB>(context).increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
