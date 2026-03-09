/// Order model representing a customer order in QuickQueue Pro.
///
/// Each order contains a token number, ordered items with quantities,
/// total price, and a status indicating preparation progress.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the lifecycle status of an order.
enum OrderStatus {
  preparing,
  ready;

  /// Convert enum to Firestore-safe string.
  String toFirestore() => name;

  /// Parse a Firestore string back into [OrderStatus].
  static OrderStatus fromFirestore(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.preparing,
    );
  }
}

class OrderModel {
  final String id;
  final int tokenNumber;
  final Map<String, int> items; // item name → quantity
  final double totalPrice;
  final OrderStatus status;
  final DateTime timestamp;
  final String vendorId;

  const OrderModel({
    required this.id,
    required this.tokenNumber,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.timestamp,
    required this.vendorId,
  });

  /// Create an [OrderModel] from a Firestore document snapshot.
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      tokenNumber: data['tokenNumber'] as int? ?? 0,
      items: Map<String, int>.from(data['items'] as Map? ?? {}),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromFirestore(data['status'] as String? ?? 'preparing'),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vendorId: data['vendorId'] as String? ?? '',
    );
  }

  /// Convert this order to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'tokenNumber': tokenNumber,
      'items': items,
      'totalPrice': totalPrice,
      'status': status.toFirestore(),
      'timestamp': Timestamp.fromDate(timestamp),
      'vendorId': vendorId,
    };
  }

  /// Create a copy with modified fields.
  OrderModel copyWith({
    String? id,
    int? tokenNumber,
    Map<String, int>? items,
    double? totalPrice,
    OrderStatus? status,
    DateTime? timestamp,
    String? vendorId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      vendorId: vendorId ?? this.vendorId,
    );
  }

  @override
  String toString() =>
      'OrderModel(token: $tokenNumber, status: ${status.name}, total: $totalPrice)';
}
