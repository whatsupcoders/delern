import 'dart:async';
import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/models/base/database_observable_list.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'deck_model.g.dart';

class DeckType extends EnumClass {
  static Serializer<DeckType> get serializer => _$deckTypeSerializer;

  @BuiltValueEnumConst(wireName: 'BASIC')
  static const DeckType basic = _$basic;

  @BuiltValueEnumConst(wireName: 'GERMAN')
  static const DeckType german = _$german;

  @BuiltValueEnumConst(wireName: 'SWISS')
  static const DeckType swiss = _$swiss;

  const DeckType._(String name) : super(name);

  static BuiltSet<DeckType> get values => _$values;
  static DeckType valueOf(String name) => _$valueOf(name);
}

abstract class DeckModel
    implements Built<DeckModel, DeckModelBuilder>, KeyedListItem {
  @nullable
  String get key;
  @nullable
  String get name;
  bool get markdown;
  @BuiltValueField(wireName: 'deckType')
  DeckType get type;
  @nullable
  bool get accepted;
  @nullable
  AccessType get access;
  DateTime get lastSyncAt;
  @nullable
  String get category;

  static Serializer<DeckModel> get serializer => _$deckModelSerializer;

  factory DeckModel([void Function(DeckModelBuilder) updates]) = _$DeckModel;
  DeckModel._();

  static DeckModel fromSnapshot({
    @required String key,
    @required Map value,
  }) {
    if (value == null) {
      return DeckModelBuilder().build();
    }
    return serializers
        .deserializeWith(DeckModel.serializer, value)
        .rebuild((b) => b..key = key);
  }

  static Stream<DeckModel> get({@required String uid, @required String key}) =>
      FirebaseDatabase.instance
          .reference()
          .child('decks')
          .child(uid)
          .child(key)
          .onValue
          .map((evt) => DeckModel.fromSnapshot(
                key: key,
                value: evt.snapshot.value,
              ));

  static DatabaseObservableList<DeckModel> getList({@required String uid}) {
    FirebaseDatabase.instance
        .reference()
        .child('decks')
        .child(uid)
        .keepSynced(true);

    return DatabaseObservableList(
        query: FirebaseDatabase.instance
            .reference()
            .child('decks')
            .child(uid)
            .orderByKey(),
        snapshotParser: (key, value) {
          _keepDeckSynced(uid, key);
          return DeckModel.fromSnapshot(key: key, value: value);
        });
  }

  static void _keepDeckSynced(String uid, String deckId) {
    // Install a background listener on Card. The listener is cancelled
    // automatically when the deck is deleted or un-shared, because the security
    // rules will not allow to listen to that node anymore.
    // ScheduledCard is synced within ScheduledCardsBloc.
    // TODO(dotdoom): these listeners are gone when we delete the last card
    //                (Firebase says "Permission denied"). What can we do?
    FirebaseDatabase.instance
        .reference()
        .child('cards')
        .child(deckId)
        .keepSynced(true);
  }
}

abstract class DeckModelBuilder
    implements Builder<DeckModel, DeckModelBuilder> {
  String key;
  String name;
  bool markdown = true;
  DeckType type = DeckType.basic;
  bool accepted = true;
  AccessType access;
  DateTime lastSyncAt = DateTime.fromMillisecondsSinceEpoch(0);
  String category;

  factory DeckModelBuilder() = _$DeckModelBuilder;
  DeckModelBuilder._();
}
