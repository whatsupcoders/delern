import 'package:flutter/material.dart';

class TextOverflowEllipsisWidget extends StatelessWidget {
  final String textDetails;
  final TextStyle primaryTextStyle;

  const TextOverflowEllipsisWidget(
      {@required this.textDetails, this.primaryTextStyle});

  @override
  Widget build(BuildContext context) => Text(
        textDetails,
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: primaryTextStyle,
      );
}
