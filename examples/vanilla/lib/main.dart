import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class CountA with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class CountB with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class Sum with ChangeNotifier {
  int get count => _countA + _countB;

  int _countA;
  int get countA => _countA;
  set countA(int value) {
    if (_countA != value) {
      _countA = value;
      notifyListeners();
    }
  }

  int _countB;
  int get countB => _countB;
  set countB(int value) {
    if (_countB != value) {
      _countB = value;
      notifyListeners();
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => CountA()),
        ChangeNotifierProvider(builder: (_) => CountB()),
        ChangeNotifierProxyProvider2<CountA, CountB, Sum>(
          initialBuilder: (_) => Sum(),
          builder: (_, a, b, model) => model
            ..countA = a.count
            ..countB = b.count,
        ),
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
            Consumer<CountA>(builder: (context, a, _) {
              return Text(
                '${a.count}',
                style: Theme.of(context).textTheme.display1,
              );
            }),
            const Text('You have pushed the bottom button this many times:'),
            Consumer<CountB>(builder: (context, b, _) {
              return Text(
                '${b.count}',
                style: Theme.of(context).textTheme.display1,
              );
            }),
            const Text('Total:'),
            Consumer<Sum>(builder: (context, sum, _) {
              return Text(
                '${sum.count}',
                style: Theme.of(context).textTheme.display1,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            onPressed: Provider.of<CountA>(context).increment,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: Provider.of<CountB>(context).increment,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
