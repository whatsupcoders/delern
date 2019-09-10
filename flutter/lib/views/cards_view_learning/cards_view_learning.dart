import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/cards_view_learning_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:flutter/material.dart';

const _kCardPageRatio = 0.9;
const double _kCardPadding = 8;

class CardsViewLearning extends StatefulWidget {
  final DeckModel deck;

  const CardsViewLearning({@required this.deck}) : assert(deck != null);

  @override
  _CardsViewLearningState createState() => _CardsViewLearningState();
}

class _CardsViewLearningState extends State<CardsViewLearning>
    with TickerProviderStateMixin {
  final PageController _controller = PageController(viewportFraction: 0.7);
  int _currentCard = 0;

  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.page.floor() != _currentCard) {
        setState(() {
          _currentCard = _controller.page.floor();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ScreenBlocView<CardsViewLearningBloc>(
        blocBuilder: (user) =>
            CardsViewLearningBloc(deck: widget.deck, user: user),
        appBarBuilder: (bloc) => AppBar(
            title: StreamBuilder<int>(
                stream: bloc.doGetNumberOfCards,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                        '(${_currentCard + 1}/${snapshot.data}) ${widget.deck.name}');
                  }
                  return Text(widget.deck.name);
                })),
        bodyBuilder: (bloc) => StreamBuilder<List<CardModel>>(
          stream: bloc.doGetCardList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return ProgressIndicatorWidget();
            } else {
              return PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          // Workaround for:
                          // https://github.com/flutter/flutter/issues/35198.
                          var page = index.toDouble();
                          if (_controller.position.minScrollExtent != null &&
                              _controller.position.maxScrollExtent != null) {
                            page = _controller.page;
                          }

                          final value = (1 - ((page - index).abs() * 0.3))
                              .clamp(0.0, 1.0);
                          final transformValue =
                              Curves.easeOut.transform(value);
                          return Center(
                              child: SizedBox(
                                  width: transformValue *
                                      MediaQuery.of(context).size.width *
                                      _kCardPageRatio,
                                  child: child));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(_kCardPadding),
                          child: FlipCardWidget(
                            front: snapshot.data[index].front,
                            back: snapshot.data[index].back,
                            gradient: specifyLearnCardBackgroundGradient(
                                widget.deck.type, snapshot.data[index].back),
                            key: ValueKey(snapshot.data[index].key),
                          ),
                        ),
                      ));
            }
          },
        ),
      );
}
