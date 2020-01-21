import 'dart:math';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/routes.dart';
import 'package:delern_flutter/view_models/decks_list_bloc.dart';
import 'package:delern_flutter/views/decks_list/create_deck_widget.dart';
import 'package:delern_flutter/views/decks_list/deck_menu.dart';
import 'package:delern_flutter/views/decks_list/navigation_drawer.dart';
import 'package:delern_flutter/views/helpers/arrow_to_fab_widget.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/edit_delete_dismissible_widget.dart';
import 'package:delern_flutter/views/helpers/empty_list_message_widget.dart';
import 'package:delern_flutter/views/helpers/learning_method_widget.dart';
import 'package:delern_flutter/views/helpers/list_accessor_widget.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/search_bar_widget.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/tags_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

class DecksList extends StatefulWidget {
  const DecksList();

  @override
  _DecksListState createState() => _DecksListState();
}

class _DecksListState extends State<DecksList> {
  // TODO(ksheremet): use ScreenBlocView to handle this bloc.
  DecksListBloc _bloc;

  @override
  void didChangeDependencies() {
    final user = CurrentUserWidget.of(context).user;
    if (_bloc?.user != user) {
      _bloc?.dispose();
      _bloc = DecksListBloc(user: user);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }

  void setFilter(String input) {
    if (input == null) {
      _bloc.decksListFilter = null;
      return;
    }
    input = input.toLowerCase();
    _bloc.decksListFilter = (d) =>
        // Case insensitive filter
        d.name.toLowerCase().contains(input);
  }

  final _fabKey = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: SearchBarWidget(
          title: localizations.of(context).listOFDecksScreenTitle,
          search: setFilter,
          leading: buildStreamBuilderWithValue<bool>(
              streamWithValue: _bloc.isOnline,
              builder: (context, snapshot) {
                final online = snapshot.data == true;
                return IconButton(
                  tooltip: online
                      ? localizations.of(context).profileTooltip
                      : localizations.of(context).offlineProfileTooltip,
                  icon: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 500),
                    firstChild: const Icon(Icons.person),
                    secondChild: const Icon(Icons.offline_bolt,
                        color: Colors.amberAccent),
                    crossFadeState: online
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ),
                  onPressed: () => _scaffoldKey.currentState.openDrawer(),
                );
              }),
        ),
        drawer: NavigationDrawer(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListAccessorWidget<DeckModel>(
                list: _bloc.decksList,
                itemBuilder: (context, item, index) {
                  final itemHeight = max(
                      MediaQuery.of(context).size.height *
                          app_styles.kItemListHeightRatio,
                      app_styles.kMinItemHeight);
                  return Column(
                    children: <Widget>[
                      if (index == 0)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height *
                                  app_styles.kItemListPaddingRatio *
                                  2),
                        ),
                      DeckListItemWidget(
                        deck: item,
                        bloc: _bloc,
                        minHeight: itemHeight,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height *
                                app_styles.kItemListPaddingRatio),
                      ),
                      if (index == (_bloc.decksList.value.length - 1))
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height *
                                  app_styles.kItemListPaddingRatio),
                        ),
                    ],
                  );
                },
                emptyMessageBuilder: () => ArrowToFloatingActionButtonWidget(
                    fabKey: _fabKey,
                    child: EmptyListMessageWidget(
                        localizations.of(context).emptyDecksList)),
              ),
            ),
          ],
        ),
        floatingActionButton: CreateDeckWidget(key: _fabKey, bloc: _bloc),
      );
}

class DeckListItemWidget extends StatelessWidget {
  final DeckModel deck;
  final DecksListBloc bloc;
  final double minHeight;

  const DeckListItemWidget(
      {@required this.deck, @required this.bloc, @required this.minHeight});

  @override
  Widget build(BuildContext context) {
    final emptyExpanded = Expanded(
      flex: 1,
      child: Container(
        color: Colors.transparent,
      ),
    );

    final iconSize = max(minHeight * 0.5, app_styles.kMinIconHeight);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        emptyExpanded,
        Expanded(
          flex: 8,
          child: EditDeleteDismissible(
            key: Key(deck.key),
            iconSize: iconSize,
            onDelete: () async {
              if (await _showDeleteDeckDialog(context)) {
                unawaited(logDeckDeleteSwipe(deck.key));
                return _deleteDeck(context);
              }
              return false;
            },
            onEdit: () {
              unawaited(logDeckEditSwipe(deck.key));
              unawaited(openEditDeckScreen(context, deckKey: deck.key));
            },
            child: Material(
              elevation: app_styles.kItemElevation,
              child: InkWell(
                onTap: () => _showLearningDialog(context),
                child: Row(
                  children: <Widget>[
                    _buildLeading(iconSize),
                    Expanded(child: _buildContent(context)),
                    _buildTrailing(context, iconSize),
                  ],
                ),
              ),
            ),
          ),
        ),
        emptyExpanded,
      ],
    );
  }

  Future<void> _showLearningDialog(BuildContext context) async {
    if (deck.cards.value.isEmpty) {
      // If deck is empty, open a screen with adding cards
      return openNewCardScreen(context, deckKey: deck.key);
    }
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      localizations.of(context).learning(deck.name),
                      style: Theme.of(context).textTheme.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  buildStreamBuilderWithValue<Set<String>>(
                    streamWithValue: deck.tags,
                    builder: (_, snapshot) => snapshot.hasData
                        ? TagsWidget(tags: snapshot.data)
                        : ProgressIndicatorWidget(),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        LearningMethodWidget(
                          name: localizations.of(context).intervalLearning,
                          tooltip:
                              localizations.of(context).intervalLearningTooltip,
                          icon: Icons.autorenew,
                          onTap: () {
                            // Close dialog
                            Navigator.pop(context);
                            openLearnCardIntervalScreen(context, deck);
                          },
                        ),
                        LearningMethodWidget(
                          name: localizations.of(context).viewLearning,
                          tooltip:
                              localizations.of(context).viewLearningTooltip,
                          icon: Icons.remove_red_eye,
                          onTap: () {
                            // Close dialog
                            Navigator.pop(context);
                            openLearnCardViewScreen(context, deck);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _buildContent(BuildContext context) {
    final primaryFontSize =
        max(minHeight * 0.25, app_styles.kMinPrimaryTextSize);
    final primaryTextStyle =
        app_styles.primaryText.copyWith(fontSize: primaryFontSize);
    final secondaryTextStyle = app_styles.secondaryText.copyWith(
        fontSize: primaryFontSize / 1.5,
        color: app_styles.kSecondaryTextDeckItemColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          deck.name,
          style: primaryTextStyle,
        ),
        buildStreamBuilderWithValue<int>(
          streamWithValue: deck.numberOfCardsDue,
          builder: (context, snapshot) => Text(
            localizations.of(context).cardsToLearnLabel(
                snapshot.data?.toString() ?? 'N/A',
                // TODO(ksheremet): Add StreamBuilder to get updates about all
                // cards
                deck.cards.value.length.toString()),
            style: secondaryTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildLeading(double size) => IconButton(
        padding: const EdgeInsets.all(app_styles.kIconDeckPadding),
        onPressed: null,
        icon: Icon(
          Icons.folder,
          color: app_styles.kIconColor,
        ),
        iconSize: size,
      );

  Widget _buildTrailing(BuildContext context, double size) => DeckMenu(
        deck: deck,
        buttonSize: size,
        onDeleteDeck: () async {
          if (await _showDeleteDeckDialog(context)) {
            unawaited(logDeckDelete(deck.key));
            await _deleteDeck(context);
          }
        },
      );

  Future<bool> _showDeleteDeckDialog(BuildContext context) {
    final locale = localizations.of(context);
    return showSaveUpdatesDialog(
        context: context,
        changesQuestion: deck.access == AccessType.owner
            ? locale.deleteDeckOwnerAccessQuestion
            : locale.deleteDeckWriteReadAccessQuestion,
        yesAnswer: locale.delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
  }

  Future<bool> _deleteDeck(BuildContext context) async {
    try {
      // Keep instance of Scaffold context. If deck is disposed and deleted
      // from widget tree it throws an exception that not possible to search
      // for Scaffold.
      final scaffoldContext = Scaffold.of(context);
      await bloc.deleteDeck(deck);
      UserMessages.showMessage(
          scaffoldContext, localizations.of(context).deckDeletedUserMessage);
      return true;
    } catch (e, stackTrace) {
      unawaited(
          UserMessages.showError(() => Scaffold.of(context), e, stackTrace));
    }
    return false;
  }
}
