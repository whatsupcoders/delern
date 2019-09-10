import 'dart:async';

import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class DeckSettingsBloc extends ScreenBloc {
  final DeckModel initialDeck;
  String _deckName;
  DeckType _deckType;

  DeckSettingsBloc({@required User user, @required this.initialDeck})
      : assert(initialDeck != null),
        super(user) {
    // TODO(ksheremet): this is usually called _initFields().
    _deckName = initialDeck.name;
    _deckType = initialDeck.type;
    _markdown = initialDeck.markdown;
    _initListeners();
  }

  final _onDeleteDeckController = StreamController<void>();
  Sink<void> get onDeleteDeck => _onDeleteDeckController.sink;

  final _onDeleteDeckIntention = StreamController<void>();
  Sink<void> get onDeleteDeckIntention => _onDeleteDeckIntention.sink;

  final _doShowConfirmationDialogController = StreamController<String>();
  Stream<String> get doShowConfirmationDialog =>
      _doShowConfirmationDialogController.stream;

  final _onDeckNameController = StreamController<String>();
  Sink<String> get onDeckName => _onDeckNameController.sink;

  final _onDeckTypeController = StreamController<DeckType>();
  Sink<DeckType> get onDeckType => _onDeckTypeController.sink;

  Future<void> _delete() {
    unawaited(logDeckDelete(initialDeck.key));
    return user.deleteDeck(deck: initialDeck);
  }

  @override
  void dispose() {
    _onDeleteDeckController.close();
    _onDeleteDeckIntention.close();
    _doShowConfirmationDialogController.close();
    _onDeckTypeController.close();
    _onDeckNameController.close();
    super.dispose();
  }

  Future<bool> _saveDeckSettings() async {
    try {
      await user.updateDeck(
          deck: initialDeck.rebuild((b) => b
            ..name = _deckName
            ..markdown = _markdown
            ..type = _deckType));
      return true;
    } catch (e, stackTrace) {
      unawaited(error_reporting.report('updateDeck', e, stackTrace));
      notifyErrorOccurred(e);
    }
    return false;
  }

  void _initListeners() {
    _onDeleteDeckController.stream.listen((_) async {
      try {
        await _delete();
        notifyPop();
      } catch (e, stackTrace) {
        unawaited(error_reporting.report('deleteDeck', e, stackTrace));
        notifyErrorOccurred(e);
      }
    });

    _onDeleteDeckIntention.stream.listen((_) {
      String deleteDeckQuestion;
      switch (initialDeck.access) {
        case AccessType.owner:
          deleteDeckQuestion = locale.deleteDeckOwnerAccessQuestion;
          break;
        case AccessType.write:
        case AccessType.read:
          deleteDeckQuestion = locale.deleteDeckWriteReadAccessQuestion;
          break;
      }
      _doShowConfirmationDialogController.add(deleteDeckQuestion);
    });

    _onDeckNameController.stream.listen((name) => _deckName = name);

    _onDeckTypeController.stream.listen((deckType) => _deckType = deckType);
  }

  @override
  @protected
  Future<bool> userClosesScreen() => _saveDeckSettings();
}
