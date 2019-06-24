import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx_provider/src/setup.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'common.dart';

void main() {
  final debugCheckInvalidValueType = Provider.debugCheckInvalidValueType;

  tearDown(() {
    Provider.debugCheckInvalidValueType = debugCheckInvalidValueType;
    consumerDelegatesBuilder.clear();
  });

  group('Setup', () {
    test('debugCheckInvalidValueType throws if used with Store', () {
      final mock = DebugCheckInvalidValueType();
      Provider.debugCheckInvalidValueType = mock;

      setupMobxProvider();

      expect(
        () => Provider.debugCheckInvalidValueType(StoreMock()),
        throwsFlutterError,
      );

      verifyZeroInteractions(mock);
    });
    test(
        'debugCheckInvalidValueType calls previous implementation if not store',
        () {
      setupMobxProvider();
      final mock = DebugCheckInvalidValueType();
      Provider.debugCheckInvalidValueType = mock;

      Provider.debugCheckInvalidValueType(42);

      verify(mock(42)).called(1);
      verifyNoMoreInteractions(mock);
    });

    testWidgets('Consumer still works without using stores', (tester) async {
      setupMobxProvider();
      await tester.pumpWidget(InheritedProvider(
        value: 42,
        child: Consumer<int>(builder: (_, store, __) {
          return Text(
            store.toString(),
            textDirection: TextDirection.ltr,
          );
        }),
      ));

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('modify Consumer to subscribe to Store', (tester) async {
      setupMobxProvider();
      final store = Counter();

      await tester.pumpWidget(InheritedProvider(
        value: store,
        child: Consumer<Counter>(builder: (_, store, __) {
          return Text(
            store.value.toString(),
            textDirection: TextDirection.ltr,
          );
        }),
      ));

      expect(find.text('0'), findsOneWidget);

      store.increment();
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });
  });
}

class DebugCheckInvalidValueType extends Mock {
  void call<T>(T value);
}
