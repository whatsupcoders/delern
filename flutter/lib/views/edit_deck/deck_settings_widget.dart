import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/edit_deck_bloc.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:flutter/material.dart';

const double _kBorderPadding = 8;
const double _kMinDeckTypeWidgetWidth = 90;
final _kItemListPadding = Container(width: _kBorderPadding * 2);

class DeckSettingsWidget extends StatefulWidget {
  final DeckModel deck;
  final EditDeckBloc bloc;

  const DeckSettingsWidget({@required this.deck, @required this.bloc})
      : assert(bloc != null);

  @override
  State<StatefulWidget> createState() => _DeckSettingsWidgetState();
}

class _DeckSettingsWidgetState extends State<DeckSettingsWidget> {
  DeckType _currentDeckType;

  @override
  void initState() {
    _currentDeckType = widget.deck.type;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final locale = localizations.of(context);
    if (widget.bloc?.locale != locale) {
      widget.bloc.onLocale.add(locale);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(_kBorderPadding),
        child: SingleChildScrollView(
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      localizations.of(context).deckType,
                      style: app_styles.primaryText,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: _kBorderPadding),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBasicDeckType(),
                        _kItemListPadding,
                        _buildGermanDeckType(),
                        _kItemListPadding,
                        _buildSwissDeckType(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildGermanDeckType() {
    final ruleList = [
      // TODO(dotdoom): Refactor: move logic to card_background_specifier
      _buildRule('der', getEditCardGradientFromGender(Gender.masculine)),
      _buildRule('die, eine', getEditCardGradientFromGender(Gender.feminine)),
      _buildRule('das', getEditCardGradientFromGender(Gender.neuter)),
      _buildRule(localizations.of(context).other,
          getEditCardGradientFromGender(Gender.noGender)),
    ];
    return _buildDeckType(DeckType.german, ruleList);
  }

  Widget _buildSwissDeckType() {
    final ruleList = [
      _buildRule('de, en', getEditCardGradientFromGender(Gender.masculine)),
      _buildRule('d, e', getEditCardGradientFromGender(Gender.feminine)),
      _buildRule('s, es', getEditCardGradientFromGender(Gender.neuter)),
      _buildRule(localizations.of(context).other,
          getEditCardGradientFromGender(Gender.noGender)),
    ];
    return _buildDeckType(DeckType.swiss, ruleList);
  }

  Widget _buildBasicDeckType() {
    final ruleList = [
      _buildRule('', getEditCardGradientFromGender(Gender.noGender)),
      _buildRule('', getEditCardGradientFromGender(Gender.noGender)),
      _buildRule('', getEditCardGradientFromGender(Gender.noGender)),
      _buildRule('', getEditCardGradientFromGender(Gender.noGender)),
    ];
    return _buildDeckType(DeckType.basic, ruleList);
  }

  Widget _buildDeckType(DeckType deckType, List<Widget> ruleList) => Material(
        color: _currentDeckType == deckType
            ? Colors.grey
            : app_styles.kScaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: InkWell(
          splashColor: Theme.of(context).splashColor,
          onTap: () {
            setState(() {
              _currentDeckType = deckType;
              widget.bloc.onDeckType.add(deckType);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(_kBorderPadding),
            child: Column(
              children: <Widget>[
                Text(_getDeckTypeName(deckType)),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: ruleList,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  String _getDeckTypeName(DeckType deckType) {
    switch (deckType) {
      case DeckType.basic:
        return localizations.of(context).basicDeckType;
      case DeckType.german:
        return localizations.of(context).germanDeckType;
      case DeckType.swiss:
        return localizations.of(context).swissDeckType;
    }
    return localizations.of(context).unknownDeckType;
  }

  Widget _buildRule(String text, Gradient gradient) => ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: _kMinDeckTypeWidgetWidth,
          minHeight: app_styles.kMinSecondaryTextSize + _kBorderPadding,
        ),
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          padding: const EdgeInsets.all(_kBorderPadding),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: app_styles.kMinSecondaryTextSize,
            ),
          ),
        ),
      );
}
