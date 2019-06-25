import 'dart:async';

import 'package:bloc/bloc.dart' as _bloc;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class BlocProvider<Value, Bloc extends _bloc.Bloc<dynamic, Value>>
    extends ValueDelegateWidget<Bloc> implements SingleChildCloneableWidget {
  /// Allows to specify parameters to [BlocProvider].
  BlocProvider({
    Key key,
    @required ValueBuilder<Bloc> builder,
    UpdateShouldNotify<Value> updateShouldNotify,
    UpdateShouldNotify<Value> blocUpdateShouldNotify,
    Disposer<Bloc> dispose,
    Widget child,
  }) : this._(
          key: key,
          delegate: BuilderStateDelegate<Bloc>(builder, dispose: dispose),
          updateShouldNotify: null,
          child: child,
        );

  /// Allows to specify parameters to [BlocProvider].
  BlocProvider.value({
    Key key,
    @required Bloc value,
    UpdateShouldNotify<Value> updateShouldNotify,
    Widget child,
  }) : this._(
          key: key,
          delegate: SingleValueDelegate<Bloc>(value),
          updateShouldNotify: updateShouldNotify,
          child: child,
        );

  BlocProvider._({
    Key key,
    @required ValueStateDelegate<Bloc> delegate,
    this.updateShouldNotify,
    this.child,
  }) : super(key: key, delegate: delegate);

  final UpdateShouldNotify<Value> updateShouldNotify;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bloc = delegate.value;
    return InheritedProvider<Bloc>(
      value: bloc,
      child: StreamProvider<Value>.value(
        initialData: bloc.initialState,
        updateShouldNotify: updateShouldNotify,
        value: bloc.state,
        child: child,
      ),
    );
  }

  @override
  BlocProvider<Value, Bloc> cloneWithChild(Widget child) {
    return BlocProvider._(
      key: key,
      delegate: delegate,
      updateShouldNotify: updateShouldNotify,
      child: child,
    );
  }
}

class BlocListener<T> extends StatefulWidget
    implements SingleChildCloneableWidget {
  BlocListener({Key key, this.bloc, this.child, this.listener})
      : super(key: key);

  final _bloc.Bloc<dynamic, T> bloc;
  final ValueChanged<T> listener;
  final Widget child;

  @override
  _BlocListenerState<T> createState() => _BlocListenerState<T>();

  @override
  BlocListener<T> cloneWithChild(Widget child) {
    return BlocListener(
      key: key,
      bloc: bloc,
      listener: listener,
      child: child,
    );
  }
}

class _BlocListenerState<T> extends State<BlocListener<T>> {
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.bloc?.state?.listen(_listener);
  }

  @override
  void didUpdateWidget(BlocListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bloc?.state != oldWidget.bloc?.state) {
      subscription?.cancel();
      subscription = widget.bloc?.state?.listen(_listener);
    }
  }

  void _listener(T value) {
    widget.listener?.call(value);
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
