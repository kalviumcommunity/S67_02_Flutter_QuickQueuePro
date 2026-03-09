/// Dashboard screen for QuickQueue Pro.
///
/// Shows real-time order list, current token, active orders count,
/// with animated list items, pull-to-refresh, and navigation actions.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/order_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/shimmer_loading.dart';
import '../animations/page_transitions.dart';
import 'add_order_screen.dart';
import 'display_mode_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final String _vendorId;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _vendorId = context.read<AuthProvider>().currentUser!.uid;
  }

  /// Navigate to Add Order screen with Hero + slide-up transition.
  void _navigateToAddOrder() {
    Navigator.of(context).push(
      SlideUpRoute(page: const AddOrderScreen()),
    );
  }

  /// Navigate to Display Mode screen.
  void _navigateToDisplayMode() {
    Navigator.of(context).push(
      FadeScaleRoute(page: const DisplayModeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QuickQueue Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          // Display Mode button
          IconButton(
            onPressed: _navigateToDisplayMode,
            icon: const Icon(Icons.tv_rounded),
            tooltip: 'Display Mode',
          ),
          // Sign out button
          IconButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await authProvider.signOut();
              }
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Statistics Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: StreamBuilder<int>(
              stream: _firestoreService.tokenStream(_vendorId),
              builder: (context, tokenSnap) {
                final currentToken = tokenSnap.data ?? 0;

                return StreamBuilder<List<OrderModel>>(
                  stream: orderProvider.ordersStream(_vendorId),
                  builder: (context, ordersSnap) {
                    final activeOrders = ordersSnap.data
                            ?.where((o) => o.status == OrderStatus.preparing)
                            .length ??
                        0;

                    return Row(
                      children: [
                        StatCard(
                          label: 'Current Token',
                          value: currentToken,
                          icon: Icons.confirmation_number_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          label: 'Active Orders',
                          value: activeOrders,
                          icon: Icons.pending_actions_rounded,
                          color: Colors.orange,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ── Section Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orders',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Swipe to update',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),

          // ── Orders List ──
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: orderProvider.ordersStream(_vendorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const OrderShimmer();
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48,
                            color: theme.colorScheme.error),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load orders',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          snapshot.error.toString(),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data ?? [];

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap + to add your first order',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Trigger a UI refresh (stream auto-updates)
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: AnimatedList(
                    key: ValueKey(orders.length),
                    initialItemCount: orders.length,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index, animation) {
                      if (index >= orders.length) {
                        return const SizedBox.shrink();
                      }
                      final order = orders[index];

                      return SizeTransition(
                        sizeFactor: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: OrderCard(
                            order: order,
                            onMarkReady: () {
                              orderProvider.markOrderReady(order.id);
                            },
                            onDelete: () {
                              orderProvider.deleteOrder(order.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ── FAB: Add Order ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddOrder,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Order',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        heroTag: 'add_order_fab',
      ),
    );
  }
}
