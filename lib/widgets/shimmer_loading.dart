/// Shimmer loading placeholder for the order list.
///
/// Displays animated placeholder cards while Firestore data loads,
/// giving users a smooth loading experience.
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrderShimmer extends StatelessWidget {
  final int itemCount;

  const OrderShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
