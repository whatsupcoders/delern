import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/routes.dart';
import 'package:delern_flutter/view_models/card_preview_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/card_display_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:flutter/material.dart';

class CardPreview extends StatefulWidget {
  final CardModel card;
  final DeckModel deck;

  const CardPreview({@required this.card, @required this.deck})
      : assert(card != null),
        assert(deck != null);

  @override
  State<StatefulWidget> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview> {
  @override
  Widget build(BuildContext context) => ScreenBlocView(
        blocBuilder: (user) {
          final bloc =
              CardPreviewBloc(user: user, card: widget.card, deck: widget.deck);
          bloc.doShowDeleteDialog
              .listen((message) => _showDeleteCardDialog(bloc, message));
          bloc.doEditCard.listen(
              (_) => openEditCardScreen(context, widget.deck, widget.card));
          return bloc;
        },
        appBarBuilder: (bloc) => AppBar(
          title: StreamBuilder<String>(
              initialData: widget.deck.name,
              stream: bloc.doDeckNameChanged,
              builder: (context, snapshot) => Text(snapshot.data)),
          actions: <Widget>[
            IconButton(
                tooltip: localizations.of(context).deleteCardTooltip,
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  bloc.onDeleteDeckIntention.add(null);
                }),
          ],
        ),
        bodyBuilder: (bloc) => Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<CardViewModel>(
                    stream: bloc.cardStream,
                    initialData: bloc.cardValue,
                    builder: (context, snapshot) => CardDisplayWidget(
                        front: snapshot.requireData.card.front,
                        back: snapshot.requireData.card.back,
                        showBack: true,
                        gradient: specifyLearnCardBackgroundGradient(
                            snapshot.requireData.deck.type,
                            snapshot.requireData.card.back)))),
            const Padding(padding: EdgeInsets.only(bottom: 100))
          ],
        ),
        floatingActionButtonBuilder: (bloc) => FloatingActionButton(
          tooltip: localizations.of(context).editCardTooltip,
          onPressed: () {
            bloc.onEditCardIntention.add(null);
          },
          child: const Icon(Icons.edit),
        ),
      );

  Future<void> _showDeleteCardDialog(
      CardPreviewBloc bloc, String deleteCardQuestion) async {
    final deleteCardDialog = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: deleteCardQuestion,
        yesAnswer: localizations.of(context).delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
    if (deleteCardDialog) {
      bloc.onDeleteCard.add(null);
    }
  }
}
