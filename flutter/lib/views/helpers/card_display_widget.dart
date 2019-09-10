import 'package:delern_flutter/views/helpers/card_decoration_widget.dart';
import 'package:delern_flutter/views/helpers/non_scrolling_markdown.dart';
import 'package:flutter/material.dart';

class CardDisplayWidget extends StatelessWidget {
  final String front;
  final String back;
  final bool showBack;
  final Gradient gradient;

  const CardDisplayWidget(
      {@required this.front,
      @required this.back,
      @required this.showBack,
      @required this.gradient});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: CardDecorationWidget(
          gradient: gradient,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: _buildCardBody(context),
          ),
        ),
      );

  List<Widget> _buildCardBody(BuildContext context) {
    final widgetList = [
      buildNonScrollingMarkdown(front, context),
    ];

    if (showBack) {
      widgetList
        ..add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 1),
        ))
        ..add(buildNonScrollingMarkdown(back, context));
    }

    return widgetList;
  }
}
