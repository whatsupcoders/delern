import 'dart:async';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/routes.dart';
import 'package:delern_flutter/view_models/cards_interval_learning_view_model.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/slow_operation_widget.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/text_overflow_ellipsis_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';

const _kCardPaddingRatio = 0.07;
// Take floating button height from source code: https://bit.ly/2y9aIM6
const BoxConstraints _kFloatingButtonHeightConstraint = BoxConstraints.tightFor(
  height: 56,
);

class CardsIntervalLearning extends StatefulWidget {
  static const routeName = '/learn-interval';

  final DeckModel deck;

  const CardsIntervalLearning({@required this.deck}) : assert(deck != null);

  @override
  State<StatefulWidget> createState() => CardsIntervalLearningState();
}

class CardsIntervalLearningState extends State<CardsIntervalLearning> {
  /// Whether the card on the display is scheduled for the time in future.
  /// Implies that the user has been asked to learn cards beyond current date,
  /// and replied positively.
  bool _learnBeyondHorizon = false;

  /// Whether we have shown at least one side of one card to the user (does not
  /// necessarily mean that they answered it).
  bool _atLeastOneCardShown = false;

  /// Number of cards the user has answered (either positively or negatively) to
  /// in this session.
  // TODO(ksheremet): rename to "Answers", also in the UI.
  int _watchedCount = 0;

  CardsIntervalLearningViewModel _viewModel;
  StreamSubscription<void> _updates;

  final _showReplyButtons = ValueNotifier<bool>(false);

  @override
  void didChangeDependencies() {
    final user = CurrentUserWidget.of(context).user;
    if (_viewModel?.user != user) {
      _viewModel =
          CardsIntervalLearningViewModel(user: user, deckKey: widget.deck.key);
      _updates?.cancel();

      _updates ??= _viewModel.updates.listen((_) {
        if (!mounted) {
          return;
        }
        _nextCardArrived();
      },
          // Tell caller that no cards were available,
          onDone: () => Navigator.of(context).pop());
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _updates?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: buildStreamBuilderWithValue<DeckModel>(
            streamWithValue: _viewModel.deck,
            builder: (context, snapshot) => snapshot.hasData
                ? TextOverflowEllipsisWidget(
                    textDetails: snapshot.data.name,
                  )
                : ProgressIndicatorWidget(),
          ),
          actions: _viewModel.card == null ? null : <Widget>[_buildPopupMenu()],
        ),
        body: _viewModel.card == null
            ? ProgressIndicatorWidget()
            : Column(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? EdgeInsets.all(MediaQuery.of(context).size.width *
                            _kCardPaddingRatio)
                        : EdgeInsets.only(
                            top: 10,
                            left: MediaQuery.of(context).size.width *
                                _kCardPaddingRatio,
                            right: MediaQuery.of(context).size.width *
                                _kCardPaddingRatio),
                    child: buildStreamBuilderWithValue<CardModel>(
                        streamWithValue: _viewModel.card,
                        builder: (context, snapshot) {
                          // TODO(dotdoom): handle removed data (in model).
                          if (!snapshot.hasData) {
                            return ProgressIndicatorWidget();
                          }
                          final card = snapshot.data;
                          // TODO(dotdoom): handle card updates.
                          return FlipCardWidget(
                            front: card.front,
                            back: card.back,
                            gradient: specifyLearnCardBackgroundGradient(
                                _viewModel.deck.value.type, card.back),
                            onFirstFlip: () {
                              _showReplyButtons.value = true;
                            },
                            key: ValueKey(card.key),
                          );
                        }),
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _showReplyButtons,
                      builder: (context, showReplyButtons, child) =>
                          showReplyButtons
                              ? _buildButtons(context)
                              : ConstrainedBox(
                                  constraints: _kFloatingButtonHeightConstraint,
                                ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      // Use SafeArea to indent the child by the amount
                      // necessary to avoid The Notch on the iPhone X,
                      // or other similar creative physical features of
                      // the display.
                      SafeArea(
                        child: Text(
                          localizations.of(context).watchedCards(_watchedCount),
                          style: app_styles.secondaryText,
                        ),
                      ),
                    ],
                  )
                ],
              ),
      );

  Widget _buildPopupMenu() => Builder(
        builder: (context) => PopupMenuButton<_CardMenuItemType>(
          tooltip: localizations.of(context).menuTooltip,
          onSelected: (itemType) => _onCardMenuItemSelected(context, itemType),
          itemBuilder: (context) => [
            for (final entry in _buildMenu(context).entries)
              PopupMenuItem<_CardMenuItemType>(
                value: entry.key,
                child: Text(entry.value),
              ),
          ],
        ),
      );

  Widget _buildButtons(BuildContext context) => SlowOperationWidget((cb) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            // heroTag - https://stackoverflow.com/questions/46509553/
            tooltip: localizations.of(context).doNotKnowCardTooltip,
            heroTag: 'dontknow',
            backgroundColor: Colors.red,
            onPressed: cb(() => _answerCard(false, context)),
            child: const Icon(Icons.clear),
          ),
          FloatingActionButton(
            tooltip: localizations.of(context).knowCardTooltip,
            heroTag: 'know',
            backgroundColor: Colors.green,
            onPressed: cb(() => _answerCard(true, context)),
            child: const Icon(Icons.check),
          ),
        ],
      ));

  Future<void> _answerCard(bool answer, BuildContext context) async {
    try {
      await _viewModel.answer(
          knows: answer, learnBeyondHorizon: _learnBeyondHorizon);
    } catch (e, stacktrace) {
      unawaited(
          UserMessages.showError(() => Scaffold.of(context), e, stacktrace));
      return;
    }

    if (mounted) {
      setState(() {
        _watchedCount++;
      });
    }
  }

  void _onCardMenuItemSelected(BuildContext context, _CardMenuItemType item) {
    switch (item) {
      case _CardMenuItemType.edit:
        if (widget.deck.access != AccessType.read) {
          openEditCardScreen(
            context,
            deckKey: _viewModel.deck.value.key,
            cardKey: _viewModel.card.value.key,
          );
        } else {
          UserMessages.showMessage(Scaffold.of(context),
              localizations.of(context).noEditingWithReadAccessUserMessage);
        }
        break;
      case _CardMenuItemType.delete:
        if (widget.deck.access != AccessType.read) {
          _deleteCard(context);
        } else {
          UserMessages.showMessage(Scaffold.of(context),
              localizations.of(context).noDeletingWithReadAccessUserMessage);
        }
        break;
    }
  }

  Future<void> _deleteCard(BuildContext context) async {
    final locale = localizations.of(context);
    final saveChanges = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: locale.deleteCardQuestion,
        yesAnswer: locale.delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
    if (saveChanges) {
      try {
        await _viewModel.deleteCard();
        UserMessages.showMessage(Scaffold.of(context),
            localizations.of(context).cardDeletedUserMessage);
      } catch (e, stackTrace) {
        unawaited(
            UserMessages.showError(() => Scaffold.of(context), e, stackTrace));
      }
    }
  }

  Future<void> _nextCardArrived() async {
    // We call setState because the next card has arrived and we have to
    // display it.
    setState(() {
      // New card arrived, do not show reply buttons.
      _showReplyButtons.value = false;
    });

    if (!_learnBeyondHorizon &&
        _viewModel.scheduledCard.repeatAt.isAfter(DateTime.now().toUtc())) {
      if (!_atLeastOneCardShown) {
        _learnBeyondHorizon = await showSaveUpdatesDialog(
                context: context,
                changesQuestion: localizations
                    .of(context)
                    .continueLearningQuestion(DateFormat.yMMMd()
                        .add_jm()
                        .format(_viewModel.scheduledCard.repeatAt)),
                noAnswer: localizations.of(context).no,
                yesAnswer: localizations.of(context).yes) ==
            true;
      }
      if (!_learnBeyondHorizon) {
        Navigator.of(context).pop();
      }
    }

    _atLeastOneCardShown = true;
  }
}

enum _CardMenuItemType { edit, delete }

Map<_CardMenuItemType, String> _buildMenu(BuildContext context) => {
      _CardMenuItemType.edit: localizations.of(context).edit,
      _CardMenuItemType.delete: localizations.of(context).delete,
    };
