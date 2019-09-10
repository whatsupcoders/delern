import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pedantic/pedantic.dart';
import 'package:url_launcher/url_launcher.dart';

class NonScrollingMarkdownWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;

  const NonScrollingMarkdownWidget({this.text, this.textStyle});

  @override
  Widget build(BuildContext context) => MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
          .copyWith(p: textStyle),
      onTapLink: (href) async {
        if (await canLaunch(href)) {
          await launch(href, forceSafariVC: false);
        } else {
          unawaited(UserMessages.showError(() => Scaffold.of(context),
              localizations.of(context).couldNotLaunchUrl(href)));
        }
      });
}
