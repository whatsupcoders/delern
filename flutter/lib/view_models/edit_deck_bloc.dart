import 'dart:async';

import 'package:delern_flutter/models/base/delayed_initialization.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/filtered_sorted_observable_list.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class EditDeckBloc extends ScreenBloc {
  DeckModel _deck;

  DelayedInitializationObservableList<CardModel> get list => _list;
  final FilteredSortedObservableList<CardModel> _list;

  set filter(Filter<CardModel> newValue) => _list.filter = newValue;
  Filter<CardModel> get filter => _list.filter;

  EditDeckBloc({@required User user, @required DeckModel deck})
      : assert(deck != null),
        _deck = deck,
        _list =
            // Analyzer bug: https://github.com/dart-lang/sdk/issues/35577.
            // ignore: unnecessary_parenthesis
            (FilteredSortedObservableList(CardModel.getList(deckKey: deck.key))
              ..comparator = (c1, c2) =>
                  c1.front.toLowerCase().compareTo(c2.front.toLowerCase())),
        super(user) {
    _doDeckChangedController.add(_deck);
    _initListeners();
  }

  final _onDeckNameController = StreamController<String>();
  Sink<String> get onDeckName => _onDeckNameController.sink;

  // This stream is used in deck settings (popup menu). To open deck settings
  // more than one time, we need a broadcast.
  final _doShowConfirmationDialogController =
      StreamController<String>.broadcast();
  Stream<String> get doShowDeleteConfirmationDialog =>
      _doShowConfirmationDialogController.stream;

  final _doDeckChangedController = StreamController<DeckModel>();
  Stream<DeckModel> get doDeckChanged => _doDeckChangedController.stream;

  final _onDeckTypeController = StreamController<DeckType>();
  Sink<DeckType> get onDeckType => _onDeckTypeController.sink;

  final _onEditCardIntentionController = StreamController<CardModel>();
  Sink<CardModel> get onEditCardIntention =>
      _onEditCardIntentionController.sink;

  final _doEditCardController = StreamController<CardModel>();
  Stream<CardModel> get doEditCard => _doEditCardController.stream;

  void _initListeners() {
    _onDeckNameController.stream.listen((name) {
      _deck = _deck.rebuild((b) => b.name = name);
      _doDeckChangedController.add(_deck);
    });

    _onDeckTypeController.stream.listen((deckType) {
      _deck = _deck.rebuild((b) => b.type = deckType);
      _doDeckChangedController.add(_deck);
    });

    _onEditCardIntentionController.stream.listen((card) {
      if (_isEditAllowed()) {
        _doEditCardController.add(card);
      } else {
        showMessage(locale.noEditingWithReadAccessUserMessage);
      }
    });
  }

  bool _isEditAllowed() => _deck.access != AccessType.read;

  @override
  @protected
  Future<bool> userClosesScreen() => _saveDeckSettings();

  Future<bool> _saveDeckSettings() async {
    try {
      await user.updateDeck(deck: _deck);
      return true;
    } catch (e, stackTrace) {
      unawaited(error_reporting.report('updateDeck', e, stackTrace));
      notifyErrorOccurred(e);
    }
    return false;
  }

  @override
  void dispose() {
    _onDeckNameController.close();
    _doShowConfirmationDialogController.close();
    _onDeckTypeController.close();
    _doDeckChangedController.close();
    _onEditCardIntentionController.close();
    _doEditCardController.close();
    super.dispose();
  }
}
