import 'dart:math';

import 'package:delern_flutter/flutter/localization.dart' as localization;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/card_decoration_widget.dart';
import 'package:delern_flutter/views/helpers/non_scrolling_markdown_widget.dart';
import 'package:flutter/material.dart';

const _kFlipCardDuration = Duration(milliseconds: 300);
const double _kCardBorderPadding = 24;

typedef CardFlipCallback = void Function();

class FlipCardWidget extends StatefulWidget {
  final String front;
  final String back;
  final Gradient gradient;
  final CardFlipCallback onFlip;

  const FlipCardWidget({
    @required this.front,
    @required this.back,
    @required this.gradient,
    // Key is needed to compare widgets. One example:
    // In ViewLearning PageView, oldWidget and widget with the same fields
    // somehow are different widgets. Therefore we compare keys of the cards
    // to make sure that they are different before resetting animation.
    // In IntervalLearning if we omit key, it compares widgets by key (which is
    // null), therefore answer buttons work incorectly.
    @required Key key,
    this.onFlip,
  })  : assert(key != null),
        super(key: key);

  @override
  _FlipCardWidgetState createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> _flipAnimation;
  Animation<double> _sizeAnimation;
  AnimationController _controller;
  // We always see the front side of the card
  bool _isFront = true;
  // the card was flipped at least once
  bool _wasFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _kFlipCardDuration);
    _sizeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.7), weight: 0.5),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 1), weight: 0.5)
    ]).animate(_controller);

    _flipAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -pi / 2), weight: 0.5),
      TweenSequenceItem(
          tween: Tween<double>(begin: pi / 2, end: 0), weight: 0.5)
    ]).animate(_controller)
      ..addListener(() {
        final shouldBeFront = _controller.value <= 0.5;
        if (_isFront != shouldBeFront) {
          setState(() {
            _isFront = shouldBeFront;
          });
          if (!_wasFlipped && !_isFront) {
            _wasFlipped = true;
            if (widget.onFlip != null) {
              widget.onFlip();
            }
          }
        }
      });
  }

  @override
  void didUpdateWidget(FlipCardWidget oldWidget) {
    // In PageView, oldWidget and widget with the same fields somehow are
    // different widgets. Therefore we compare keys of the cards
    // to make sure that they are different before resetting animation.
    if (oldWidget != widget && oldWidget.key != widget.key) {
      // Reset animation when new card arrived
      _controller.reset();
      _wasFlipped = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _startAnimation() {
    if (!mounted) {
      return;
    }
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) => Transform.scale(
            scale: _sizeAnimation.value,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value),
              child: child,
            ),
          ),
      child: GestureDetector(
        onTap: () {
          // If card is not turning now, turn card
          if (!_controller.isAnimating) {
            _startAnimation();
          }
        },
        child: Stack(
          children: <Widget>[
            CardDecorationWidget(
              gradient: widget.gradient,
              child: Padding(
                padding: const EdgeInsets.all(_kCardBorderPadding),
                child: LayoutBuilder(
                  builder: (context, viewportConstraints) =>
                      SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: NonScrollingMarkdownWidget(
                            text: _isFront ? widget.front : widget.back,
                            textStyle: app_styles.primaryText)),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 1, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.autorenew,
                      color: app_styles.kSecondaryTextDeckItemColor,
                    ),
                    Text(
                      localization.of(context).flip,
                      style: app_styles.secondaryText.copyWith(
                          color: app_styles.kSecondaryTextDeckItemColor),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ));
}
