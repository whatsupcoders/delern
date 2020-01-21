import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_change_record.dart';
import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

// https://github.com/dart-lang/linter/issues/1826
// ignore: one_member_abstracts
abstract class ListAccessor<T> implements StreamWithValue<BuiltList<T>> {
  void close();
}

@immutable
class DataListAccessorItem<T extends KeyedListItem>
    implements StreamWithValue<T> {
  final String key;
  final DataListAccessor<T> _listAccessor;

  const DataListAccessorItem._(this._listAccessor, this.key);

  /// Whether the underlying list is fully loaded and there is currently an item
  /// with this [key] in the list.
  @override
  bool get hasValue =>
      _listAccessor.hasValue && _listAccessor.value.indexOfKey(key) >= 0;

  /// There's the following contract to [updates] of a list item:
  /// - when an item is gone from the list, this stream yields `null`, but the
  ///   stream itself is not closed. If the item re-appears, it will be yielded;
  /// - when the list itself is gone (e.g. we are watching a Card in a Deck that
  ///   has been removed), then nothing is yielded and the stream is closed.
  @override
  Stream<T> get updates async* {
    await for (final listChangedRecord in _listAccessor.events) {
      final addedItem = listChangedRecord.added
          .firstWhere((item) => item.key == key, orElse: () => null);
      final itemWasRemoved =
          listChangedRecord.removed.any((item) => item.key == key);
      if (addedItem != null || itemWasRemoved) {
        yield addedItem;
      }
    }
  }

  /// If the underlying list is fully loaded, and there is currently an item
  /// with this [key] in the list, returns the value. Otherwise, returns `null`.
  @override
  T get value {
    if (_listAccessor.hasValue) {
      final index = _listAccessor.value.indexOfKey(key);
      if (index >= 0) {
        return _listAccessor.value[index];
      }
    }
    return null;
  }
}

abstract class DataListAccessor<T extends KeyedListItem>
    implements ListAccessor<T> {
  final List<T> _currentValue = [];
  bool _loaded = false;
  final _value = StreamController<BuiltList<T>>.broadcast();
  final _events = StreamController<ListChangeRecord<T>>.broadcast();

  /// Current value of the list. The following edge cases exist:
  /// - the value is `null` if initialization is not yet complete ([hasValue] is
  ///   false);
  /// - if the `ListAccessor` has been [close]d, the value is an empty list.
  @override
  BuiltList<T> get value => _loaded ? BuiltList.from(_currentValue) : null;

  /// `true` once the initial value has been loaded from the database. Never
  /// changes to `false` afterwards.
  @override
  bool get hasValue => _loaded;

  /// Updates to the current [value]. This stream is closed when this object is
  /// [close]d.
  @override
  Stream<BuiltList<T>> get updates => _value.stream;

  /// Updates to the current [value] described in the form of
  /// [ListChangeRecord]. This stream is closed when this object is  [close]d.
  Stream<ListChangeRecord<T>> get events => _events.stream;

  StreamSubscription<Event> _onChildAdded, _onChildChanged, _onChildRemoved;

  DataListAccessor(DatabaseReference reference) {
    // TODO(dotdoom): onError handler should close().
    _onChildAdded = reference.onChildAdded.listen(_childAddedOrChanged);
    _onChildChanged = reference.onChildChanged.listen(_childAddedOrChanged);
    _onChildRemoved = reference.onChildRemoved.listen((data) {
      final index = _currentValue.indexOfKey(data.snapshot.key);
      final deletedItem = _currentValue[index];
      _currentValue.removeAt(index);
      disposeItem(deletedItem);
      if (_loaded) {
        if (_value.hasListener) {
          _value.add(BuiltList.from(_currentValue));
        }
        if (_events.hasListener) {
          _events.add(
              ListChangeRecord<T>.remove(_currentValue, index, [deletedItem]));
        }
      }
    });
    // onChildAdded listener will be called first, but we don't send updates
    // until we get the full list value.
    reference.once().then((val) {
      _loaded = true;
      // TODO(dotdoom): replace/update current value with val.

      if (_value.hasListener) {
        _value.add(BuiltList.from(_currentValue));
      }
      if (_events.hasListener) {
        _events.add(
            ListChangeRecord<T>.add(_currentValue, 0, _currentValue.length));
      }
    });
  }

  void _childAddedOrChanged(Event data) {
    final existingIndex = _currentValue.indexOfKey(data.snapshot.key);
    if (existingIndex >= 0) {
      final replacedItem = _currentValue[existingIndex];
      _currentValue[existingIndex] =
          updateItem(replacedItem, data.snapshot.key, data.snapshot.value);
      if (_loaded && _events.hasListener) {
        _events.add(ListChangeRecord<T>.replace(
            _currentValue, existingIndex, [replacedItem]));
      }
    } else {
      _currentValue.add(parseItem(data.snapshot.key, data.snapshot.value));
      if (_loaded && _events.hasListener) {
        _events.add(ListChangeRecord<T>.add(
            _currentValue, _currentValue.length - 1, 1));
      }
    }
    if (_loaded && _value.hasListener) {
      _value.add(BuiltList.from(_currentValue));
    }
  }

  DataListAccessorItem<T> getItem(String key) =>
      DataListAccessorItem._(this, key);

  @protected
  T parseItem(String key, value);

  @protected
  T updateItem(T previous, String key, value) => parseItem(key, value);

  @protected
  void disposeItem(T item) {}

  /// Close this object and release associated resources. Typically used only
  /// when the parent object is being removed from the database, or current user
  /// looses access to this object.
  @override
  void close() {
    _currentValue
      ..forEach(disposeItem)
      ..clear();
    _onChildAdded?.cancel();
    _onChildChanged?.cancel();
    _onChildRemoved?.cancel();
    _events?.close();
  }
}

typedef Filter<T> = bool Function(T item);

/// We use Decorator pattern because _base is an abstract class.
class FilteredListAccessor<T extends KeyedListItem> implements ListAccessor<T> {
  final ListAccessor<T> _base;
  Filter<T> _filter;
  BuiltList<T> _currentValue;
  StreamSubscription<BuiltList<T>> _baseValueSubscription;
  final _value = StreamController<BuiltList<T>>.broadcast();

  FilteredListAccessor(this._base) : _currentValue = _base.value {
    _baseValueSubscription = _base.updates.listen((_) => _updateCurrentValue());
  }

  Filter<T> get filter => _filter;
  set filter(Filter<T> value) {
    _filter = value;
    _updateCurrentValue();
  }

  @override
  Stream<BuiltList<T>> get updates => _value.stream;
  @override
  BuiltList<T> get value => _currentValue;
  @override
  bool get hasValue => _base.hasValue;

  @override
  void close() {
    _value.close();
    _baseValueSubscription.cancel();
  }

  void _updateCurrentValue() {
    if (_filter == null) {
      _currentValue = _base.value;
    } else {
      _currentValue = BuiltList<T>.of(_base.value.where(_filter));
    }
    _value.add(_currentValue);
  }
}
