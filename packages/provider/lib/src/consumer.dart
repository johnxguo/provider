import 'package:flutter/widgets.dart';

import 'provider.dart';

/// An object associated to [Consumer] to customize the [Consumer.builder] behavior.
///
/// It is associated to one and only one [Consumer] at a time, but a [Consumer]
/// may be associated to multiple [ConsumerDelegate].
///
/// [ConsumerDelegate] is typically used by plugins, like `provider_mobx`.
///
/// See also:
///
///   * [Consumer], which a [ConsumerDelegate] is associated with.
///   * [consumerDelegateBuilders], which is used to create a [ConsumerDelegate]
///     when a [Consumer] is inserted in the widget tree.
abstract class ConsumerDelegate {
  /// A middleware that wraps [Consumer.builder].
  ///
  /// It is expected to always call `next`, but can do things before and after.
  @protected
  Widget build(Widget next());

  /// Ask the associated [Consumer] to rebuild.
  @protected
  void markNeedsBuild() => _element.markNeedsBuild();

  Element _element;

  /// The [BuildContext] of the associated [Consumer].
  @protected
  BuildContext get context => _element;

  /// A hook on the moment where [Consumer] is removed from the tree.
  @protected
  void dispose() {}
}

typedef ConsumerDelegateBuilder = ConsumerDelegate Function();

/// A set of functions used to create a [ConsumerDelegate].
///
/// [Consumer] will call these functions when inserted in the widget tree,
/// to create a [ConsumerDelegate].
final Set<ConsumerDelegateBuilder> consumerDelegateBuilders =
// ignore: prefer_collection_literals, we want to support sdk < 2.2.2
    Set<ConsumerDelegateBuilder>();

/// {@template provider.consumer}
/// Obtain [Provider<T>] from its ancestors and pass its value to [builder].
///
/// [builder] must not be null and may be called multiple times (such as when provided value change).
///
/// ## Performance optimizations:
///
/// {@macro provider.consumer.child}
/// {@endtemplate}
class Consumer<T> extends _ConsumerBase {
  /// {@template provider.consumer.constructor}
  /// Consumes a [Provider<T>]
  /// {@endtemplate}
  Consumer({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  // fork of the documentation from https://docs.flutter.io/flutter/widgets/AnimatedBuilder/child.html
  /// The child widget to pass to [builder].
  /// {@template provider.consumer.child}
  ///
  /// If a builder callback's return value contains a subtree that does not depend on the provided value,
  /// it's more efficient to build that subtree once instead of rebuilding it on every change of the provided value.
  ///
  /// If the pre-built subtree is passed as the child parameter, [Consumer] will pass it back to the builder function so that it can be incorporated into the build.
  ///
  /// Using this pre-built child is entirely optional, but can improve performance significantly in some cases and is therefore a good practice.
  /// {@endtemplate}
  final Widget child;

  /// {@template provider.consumer.builder}
  /// Build a widget tree based on the value from a [Provider<T>].
  ///
  /// Must not be null.
  /// {@endtemplate}
  final Widget Function(BuildContext context, T value, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      Provider.of<T>(context),
      child,
    );
  }
}

abstract class _ConsumerBase extends StatefulWidget {
  _ConsumerBase({Key key}) : super(key: key);

  @protected
  Widget build(BuildContext context);

  @override
  _ConsumerState createState() => _ConsumerState();
}

class _ConsumerState extends State<_ConsumerBase> {
  List<ConsumerDelegate> delegates;

  @override
  void initState() {
    super.initState();
    delegates = consumerDelegateBuilders
        .map((f) => f().._element = context as Element)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var next = () => widget.build(context);

    for (final delegate in delegates.reversed) {
      final currentNext = next;
      next = () => delegate.build(currentNext);
    }

    return next();
  }

  @override
  void dispose() {
    for (final delegate in delegates) {
      delegate.dispose();
    }
    super.dispose();
  }
}

/// {@macro provider.consumer}
class Consumer2<A, B> extends _ConsumerBase {
  /// {@macro provider.consumer.constructor}
  Consumer2({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  /// The child widget to pass to [builder].
  ///
  /// {@macro provider.consumer.child}
  final Widget child;

  /// {@macro provider.consumer.builder}
  final Widget Function(BuildContext context, A value, B value2, Widget child)
      builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      Provider.of<A>(context),
      Provider.of<B>(context),
      child,
    );
  }
}

/// {@macro provider.consumer}
class Consumer3<A, B, C> extends _ConsumerBase {
  /// {@macro provider.consumer.constructor}
  Consumer3({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  /// The child widget to pass to [builder].
  ///
  /// {@macro provider.consumer.child}
  final Widget child;

  /// {@macro provider.consumer.builder}
  final Widget Function(
      BuildContext context, A value, B value2, C value3, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      Provider.of<A>(context),
      Provider.of<B>(context),
      Provider.of<C>(context),
      child,
    );
  }
}

/// {@macro provider.consumer}
class Consumer4<A, B, C, D> extends _ConsumerBase {
  /// {@macro provider.consumer.constructor}
  Consumer4({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  /// The child widget to pass to [builder].
  ///
  /// {@macro provider.consumer.child}
  final Widget child;

  /// {@macro provider.consumer.builder}
  final Widget Function(BuildContext context, A value, B value2, C value3,
      D value4, Widget child) builder;
  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      Provider.of<A>(context),
      Provider.of<B>(context),
      Provider.of<C>(context),
      Provider.of<D>(context),
      child,
    );
  }
}

/// {@macro provider.consumer}
class Consumer5<A, B, C, D, E> extends _ConsumerBase {
  /// {@macro provider.consumer.constructor}
  Consumer5({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  /// The child widget to pass to [builder].
  ///
  /// {@macro provider.consumer.child}
  final Widget child;

  /// {@macro provider.consumer.builder}
  final Widget Function(BuildContext context, A value, B value2, C value3,
      D value4, E value5, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      Provider.of<A>(context),
      Provider.of<B>(context),
      Provider.of<C>(context),
      Provider.of<D>(context),
      Provider.of<E>(context),
      child,
    );
  }
}

/// {@macro provider.consumer}
class Consumer6<A, B, C, D, E, F> extends _ConsumerBase {
  /// {@macro provider.consumer.constructor}
  Consumer6({
    Key key,
    @required this.builder,
    this.child,
  })  : assert(builder != null),
        super(key: key);

  /// The child widget to pass to [builder].
  ///
  /// {@macro provider.consumer.child}
  final Widget child;

  /// {@macro provider.consumer.builder}
  final Widget Function(BuildContext context, A value, B value2, C value3,
      D value4, E value5, F value6, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      Provider.of<A>(context),
      Provider.of<B>(context),
      Provider.of<C>(context),
      Provider.of<D>(context),
      Provider.of<E>(context),
      Provider.of<F>(context),
      child,
    );
  }
}
