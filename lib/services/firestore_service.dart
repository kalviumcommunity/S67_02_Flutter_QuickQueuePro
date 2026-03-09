/// Firestore service for QuickQueue Pro.
///
/// Handles all Firestore CRUD operations for orders and vendor data,
/// including token number management and real-time streams.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  // VENDOR OPERATIONS
  // ──────────────────────────────────────────────

  /// Ensure vendor document exists with initial token counter.
  Future<void> initVendor(String vendorId) async {
    final doc = _db.collection('vendors').doc(vendorId);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({'currentToken': 0});
    }
  }

  /// Get the current token number for a vendor.
  Future<int> getCurrentToken(String vendorId) async {
    final doc = await _db.collection('vendors').doc(vendorId).get();
    return (doc.data()?['currentToken'] as int?) ?? 0;
  }

  /// Atomically increment the token counter and return the new value.
  Future<int> incrementToken(String vendorId) async {
    final docRef = _db.collection('vendors').doc(vendorId);

    return _db.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(docRef);
      final current = (snapshot.data()?['currentToken'] as int?) ?? 0;
      final next = current + 1;
      transaction.update(docRef, {'currentToken': next});
      return next;
    });
  }

  /// Stream the vendor document for real-time token updates.
  Stream<int> tokenStream(String vendorId) {
    return _db.collection('vendors').doc(vendorId).snapshots().map(
          (snap) => (snap.data()?['currentToken'] as int?) ?? 0,
        );
  }

  // ──────────────────────────────────────────────
  // ORDER OPERATIONS
  // ──────────────────────────────────────────────

  /// Add a new order document to Firestore.
  Future<void> addOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set(order.toFirestore());
  }

  /// Update the status of an existing order.
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.toFirestore(),
    });
  }

  /// Delete an order document.
  Future<void> deleteOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).delete();
  }

  /// Stream active orders (Preparing + Ready) for a vendor, ordered by token ascending.
  Stream<List<OrderModel>> ordersStream(String vendorId) {
    return _db
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snapshot) {
      final orders =
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      orders.sort((a, b) => a.tokenNumber.compareTo(b.tokenNumber));
      return orders;
    });
  }

  /// Stream only orders with status "preparing".
  Stream<List<OrderModel>> preparingOrdersStream(String vendorId) {
    return _db
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId)
        .where('status', isEqualTo: OrderStatus.preparing.toFirestore())
        .snapshots()
        .map((snapshot) {
      final orders =
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      orders.sort((a, b) => a.tokenNumber.compareTo(b.tokenNumber));
      return orders;
    });
  }

  /// Stream the latest ready order for the Display Mode screen.
  Stream<OrderModel?> latestReadyOrderStream(String vendorId) {
    return _db
        .collection('orders')
        .where('vendorId', isEqualTo: vendorId)
        .where('status', isEqualTo: OrderStatus.ready.toFirestore())
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final orders =
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return orders.first;
    });
  }
}
