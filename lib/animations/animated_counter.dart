/// Animated counter widget for QuickQueue Pro.
///
/// Smoothly animates between number values using AnimatedSwitcher
/// with a slide + fade combination for a polished effect.
library;

import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String? prefix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        '${prefix ?? ''}$value',
        key: ValueKey<int>(value),
        style: style,
      ),
    );
  }
}

/// Animated price counter that smoothly transitions between double values.
class AnimatedPriceCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String currency;

  const AnimatedPriceCounter({
    super.key,
    required this.value,
    this.style,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '$currency ${animatedValue.toStringAsFixed(0)}',
          style: style,
        );
      },
    );
  }
}
