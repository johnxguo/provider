import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

class _MobxConsumerDelegate extends ConsumerDelegate {
  ReactionDisposer disposer;

  @override
  Widget build(Widget Function() next) {
    Widget built;
    // TODO: use the same logic as Observer
    disposer?.call();
    disposer = autorun((_) {
      if (built != null) {
        markNeedsBuild();
        return;
      }
      built = next();
    });
    return built;
  }

  @override
  void dispose() {
    disposer?.call();
    super.dispose();
  }
}

ConsumerDelegate _consumerDelegateBuilder() {
  return _MobxConsumerDelegate();
}

// TODO: test that setup twice does not add a consumer delegate again

void setupMobxProvider() {
  final previous = Provider.debugCheckInvalidValueType;

  consumerDelegatesBuilder.add(_consumerDelegateBuilder);

  Provider.debugCheckInvalidValueType = <T>(T value, {bool listen}) {
    assert(() {
      if (value is Store) {
        throw FlutterError('''
Tried to use Provider with a subtype of Store ($T).

This is likely a mistake, as Provider will not automatically update dependents
when $T is updated. Instead, consider changing Provider for more specific
implementation that handles the update mecanism, such as:

- StoreProvider

Alternatively, if you are making your own provider, consider using InheritedProvider.

If you think that this is not an error, you can disable this check by setting
Provider.debugCheckInvalidValueType to `null` in your main file:

```
void main() {
  Provider.debugCheckInvalidValueType = null;

  runApp(MyApp());
}
```
        ''');
      }
      previous(value);
      return true;
    }());
  };
}
