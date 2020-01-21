import 'package:delern_flutter/l10n/app_localizations.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

void main() {
  const timeoutDuration = Duration(seconds: 15);

  group('main test', () {
    FlutterDriver driver;
    AppLocalizations localizations;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      localizations = AppLocalizations();
    });

    tearDownAll(() async {
      unawaited(driver?.close());
    });

    test('skip_intro', () async {
      final skipButton = find.text('SKIP');
      await driver.waitFor(skipButton);
      await driver.tap(skipButton);
      final doneButton = find.text('DONE');
      await driver.waitFor(doneButton);
      await driver.tap(doneButton);
    });

    test('signin_anonymously', () async {
      final button = find.text('Continue Anonymously');
      await driver.waitFor(button);
      await driver.tap(button);
    });

    test('create_deck', () async {
      final fab = find.byType('FloatingActionButton');
      await driver.waitFor(fab, timeout: timeoutDuration);
      await driver.tap(fab);

      final add = find.text('ADD');
      await driver.waitFor(add);
      await driver.enterText('My Test Deck');
      await driver.waitFor(find.text('My Test Deck'));
      // When text was entered business logic needs some time to enable
      // "Add" button. Otherwise disabled button will be clicked and test fails.
      await Future.delayed(const Duration(seconds: 1));
      await driver.tap(add, timeout: timeoutDuration);
    });

    test('create_card', () async {
      final frontInput = find.byValueKey('frontCardInput');
      await driver.waitFor(frontInput, timeout: timeoutDuration);
      await driver.enterText('front1');

      await driver.tap(find.byValueKey('backCardInput'),
          timeout: timeoutDuration);
      await driver.enterText('back1');
      await driver.tap(find.byTooltip(localizations.addCardTooltip),
          timeout: timeoutDuration);

      await driver.waitFor(find.text(localizations.cardAddedUserMessage),
          timeout: timeoutDuration);
      await driver.tap(find.pageBack());
    });

    test('learn_card', () async {
      await driver.tap(find.byType('DeckListItemWidget'));
      await driver.tap(find.byTooltip(localizations.intervalLearningTooltip));

      // TODO(ksheremet): getText doesn't work with TextSpan which is used
      // in Markdown text https://github.com/flutter/flutter/issues/16013
      //expect(await driver.getText(find.text('front1')), 'front1');

      final card =
          await driver.getWidgetDiagnostics(find.byType('FlipCardWidget'));
      assert(card['front'], 'front1');
      assert(card['back'], 'back1');

      await driver.tap(find.byType('CardDecorationWidget'));
      await driver.tap(find.byTooltip(localizations.knowCardTooltip));
    });

    test('view_learn_card', () async {
      await driver.tap(find.byType('DeckListItemWidget'));
      await driver.tap(find.byTooltip(localizations.viewLearningTooltip));
      await driver.waitFor(find.text('(1/1) My Test Deck'));

      // TODO(ksheremet): getText doesn't work with TextSpan which is used
      // in Markdown text https://github.com/flutter/flutter/issues/16013
      //expect(await driver.getText(find.text('front1')), 'front1');

      var card =
          await driver.getWidgetDiagnostics(find.byType('FlipCardWidget'));
      assert(card['front'], 'front1');
      assert(card['back'], 'back1');

      await driver.tap(find.byType('CardDecorationWidget'));
      await driver.tap(find.byTooltip(localizations.shuffleTooltip));
      await driver.waitFor(find.text('(1/1) My Test Deck'));
      await driver.tap(find.byType('CardDecorationWidget'));

      card = await driver.getWidgetDiagnostics(find.byType('FlipCardWidget'));
      assert(card['front'], 'front1');
      assert(card['back'], 'back1');
    });
  });
}
