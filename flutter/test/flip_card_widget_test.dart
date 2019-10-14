import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/card_decoration_widget.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flip card', (tester) async {
    const frontSide = 'der Vater';
    const backSide = 'father';
    var _wasFlipped = false;

    // Widget must be wrapped in MaterialApp widget because it uses material
    // related classes.
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
      ],
      home: FlipCardWidget(
        front: frontSide,
        back: backSide,
        gradient: getLearnCardGradientFromGender(Gender.masculine),
        onFlip: () {
          _wasFlipped = true;
        },
        key: UniqueKey(),
      ),
    ));
    await tester.pumpAndSettle();
    _expectText(tester.allWidgets, frontSide);
    // Back side wasn't showed
    assert(!_wasFlipped);
    await tester.tap(find.byType(CardDecorationWidget));
    await tester.pumpAndSettle();
    _expectText(tester.allWidgets, backSide);
    // Back side was showed
    assert(_wasFlipped);
  });
}

void _expectText(Iterable<Widget> widgets, String string) {
  for (final widget in widgets) {
    if (widget is RichText) {
      final TextSpan span = widget.text;
      final text = _extractTextFromTextSpan(span);
      expect(text, equals(string));
      // No need to iterate more after the RichText
      break;
    }
  }
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
