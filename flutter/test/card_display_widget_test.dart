import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/card_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Display card with 2 MarkdownBody', (tester) async {
    const frontSide = 'die Mutter';
    const backSide = 'mother';

    // Widget must be wrapped in MaterialApp widget because it uses material
    // related classes.
    await tester.pumpWidget(MaterialApp(
      home: CardDisplayWidget(
        front: frontSide,
        back: backSide,
        gradient: getLearnCardGradientFromGender(Gender.feminine),
        showBack: true,
      ),
    ));

    // Make sure that we have 2 Markdown widgets
    expect(find.byWidgetPredicate((widget) => widget is MarkdownBody),
        findsNWidgets(2));

    // Iterate all widgets. Compare first Markdown with front side and the
    // second Markdown with the back side
    var markdownWidgetCount = 0;
    for (final widget in tester.allWidgets) {
      if (widget is RichText) {
        final TextSpan span = widget.text;
        final text = _extractTextFromTextSpan(span);
        if (markdownWidgetCount == 0) {
          expect(text, equals(frontSide));
          markdownWidgetCount++;
        } else {
          expect(text, equals(backSide));
        }
      }
    }
  });
}

String _extractTextFromTextSpan(TextSpan span) {
  final textBuffer = StringBuffer(span.text ?? '');
  if (span.children != null) {
    for (final child in span.children) {
      textBuffer.write(_extractTextFromTextSpan(child));
    }
  }
  return textBuffer.toString();
}
