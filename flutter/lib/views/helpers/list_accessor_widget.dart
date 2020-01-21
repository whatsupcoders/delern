import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef ListAccessorItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  // TODO(dotdoom): consider usefulness of index.
  int index,
);

typedef WidgetBuilder = Widget Function();

class ListAccessorWidget<T extends KeyedListItem> extends StatefulWidget {
  const ListAccessorWidget({
    @required this.list,
    @required this.itemBuilder,
    @required this.emptyMessageBuilder,
    this.controller,
    Key key,
  })  : assert(itemBuilder != null),
        super(key: key);

  final ListAccessor<T> list;
  final ListAccessorItemBuilder<T> itemBuilder;
  final WidgetBuilder emptyMessageBuilder;
  final ScrollController controller;

  @override
  _ListAccessorWidgetState<T> createState() => _ListAccessorWidgetState<T>();
}

class _ListAccessorWidgetState<T extends KeyedListItem>
    extends State<ListAccessorWidget<T>> {
  StreamSubscription<BuiltList<T>> _listValueSubscription;
  BuiltList<T> _list;

  @override
  void initState() {
    _list = widget.list.value;
    _listValueSubscription = widget.list.updates.listen((value) => setState(() {
          _list = value;
        }));
    super.initState();
  }

  @override
  void dispose() {
    _listValueSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.list.hasValue) {
      return ProgressIndicatorWidget();
    }
    if (_list.isEmpty) {
      return widget.emptyMessageBuilder();
    }
    // We can add a spare item at the bottom of the list to make an offset, so
    // that FloatingActionButton does not cover the last item. Make a guess
    // whether it's needed.
    // Note that for non-full-screen list, this may be unnecessary, because FAB
    // may never interfere with the list. If such a need arises, this logic will
    // have to be changed (e.g. passed as a ListAccessorWidget parameter).
    final showSpareItem =
        Scaffold.of(context, nullOk: true)?.hasFloatingActionButton == true;
    return ListView.builder(
      itemBuilder: (context, index) => index == _list.length
          // It's hard to know exactly the size of FAB because it's dynamic.
          ? SizedBox(height: kFloatingActionButtonMargin * 3)
          : widget.itemBuilder(context, _list[index], index),
      itemCount: showSpareItem ? _list.length + 1 : _list.length,
      controller: widget.controller,
    );
  }
}
