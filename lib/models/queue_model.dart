class QueueModel {
  final String id;
  final String vendorId;
  final String vendorName;
  final int tokenNumber;
  final String status; // waiting | serving | completed | cancelled
  final String? customerId;
  final String? customerName;
  final int estimatedWaitMinutes;
  final DateTime createdAt;
  final DateTime? servedAt;

  QueueModel({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.tokenNumber,
    required this.status,
    this.customerId,
    this.customerName,
    required this.estimatedWaitMinutes,
    required this.createdAt,
    this.servedAt,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      id: json['id'].toString(),
      vendorId: json['vendor_id'].toString(),
      vendorName: json['vendor_name'] as String,
      tokenNumber: json['token_number'] as int,
      status: json['status'] as String,
      customerId: json['customer_id']?.toString(),
      customerName: json['customer_name'] as String?,
      estimatedWaitMinutes: json['estimated_wait_minutes'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      servedAt: json['served_at'] != null
          ? DateTime.parse(json['served_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendor_id': vendorId,
    'vendor_name': vendorName,
    'token_number': tokenNumber,
    'status': status,
    'customer_id': customerId,
    'customer_name': customerName,
    'estimated_wait_minutes': estimatedWaitMinutes,
    'created_at': createdAt.toIso8601String(),
    'served_at': servedAt?.toIso8601String(),
  };

  bool get isWaiting   => status == 'waiting';
  bool get isServing   => status == 'serving';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
