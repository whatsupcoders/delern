import 'package:flutter/material.dart';

class TextOverflowEllipsisWidget extends StatelessWidget {
  final String textDetails;

  const TextOverflowEllipsisWidget({@required this.textDetails});

  @override
  Widget build(BuildContext context) => Text(
        textDetails,
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      );
}
