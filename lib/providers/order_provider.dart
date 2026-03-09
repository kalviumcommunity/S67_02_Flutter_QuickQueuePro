/// Order provider for QuickQueue Pro.
///
/// Manages order state, cart operations for the Add Order screen,
/// and provides streams from Firestore for real-time updates.
library;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/menu_item.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  // ──────────────────────────────────────────────
  // CART STATE (for Add Order screen)
  // ──────────────────────────────────────────────

  /// Cart: maps menu item name → quantity.
  final Map<String, int> _cart = {};
  bool _isSubmitting = false;

  Map<String, int> get cart => Map.unmodifiable(_cart);
  bool get isSubmitting => _isSubmitting;

  /// Total number of items in the cart.
  int get totalItems => _cart.values.fold(0, (sum, qty) => sum + qty);

  /// Calculate total price based on current cart.
  double get totalPrice {
    double total = 0;
    for (final entry in _cart.entries) {
      final item = MenuItems.items.firstWhere(
        (m) => m.name == entry.key,
        orElse: () => const MenuItem(name: '', price: 0, icon: Icons.error),
      );
      total += item.price * entry.value;
    }
    return total;
  }

  /// Add one unit of an item to the cart.
  void addItem(String itemName) {
    _cart[itemName] = (_cart[itemName] ?? 0) + 1;
    notifyListeners();
  }

  /// Remove one unit of an item from the cart.
  void removeItem(String itemName) {
    if (_cart.containsKey(itemName)) {
      if (_cart[itemName]! <= 1) {
        _cart.remove(itemName);
      } else {
        _cart[itemName] = _cart[itemName]! - 1;
      }
      notifyListeners();
    }
  }

  /// Get quantity of a specific item in the cart.
  int getQuantity(String itemName) => _cart[itemName] ?? 0;

  /// Clear the cart.
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // ORDER SUBMISSION
  // ──────────────────────────────────────────────

  /// Submit the current cart as a new order.
  ///
  /// Increments the vendor token, creates the order doc,
  /// and clears the cart on success.
  Future<int?> submitOrder(String vendorId) async {
    if (_cart.isEmpty) return null;

    _isSubmitting = true;
    notifyListeners();

    try {
      // Atomically get the next token number.
      final tokenNumber = await _firestoreService.incrementToken(vendorId);

      final order = OrderModel(
        id: _uuid.v4(),
        tokenNumber: tokenNumber,
        items: Map<String, int>.from(_cart),
        totalPrice: totalPrice,
        status: OrderStatus.preparing,
        timestamp: DateTime.now(),
        vendorId: vendorId,
      );

      await _firestoreService.addOrder(order);
      _cart.clear();

      _isSubmitting = false;
      notifyListeners();
      return tokenNumber;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // ORDER STATUS MANAGEMENT
  // ──────────────────────────────────────────────

  /// Mark an order as ready.
  Future<void> markOrderReady(String orderId) async {
    await _firestoreService.updateOrderStatus(orderId, OrderStatus.ready);
  }

  /// Delete a completed order.
  Future<void> deleteOrder(String orderId) async {
    await _firestoreService.deleteOrder(orderId);
  }

  // ──────────────────────────────────────────────
  // STREAMS (for real-time UI updates)
  // ──────────────────────────────────────────────

  /// Stream of all orders for a vendor.
  Stream<List<OrderModel>> ordersStream(String vendorId) =>
      _firestoreService.ordersStream(vendorId);

  /// Stream of the current token number.
  Stream<int> tokenStream(String vendorId) =>
      _firestoreService.tokenStream(vendorId);

  /// Stream of the latest ready order (for Display Mode).
  Stream<OrderModel?> latestReadyOrderStream(String vendorId) =>
      _firestoreService.latestReadyOrderStream(vendorId);
}
