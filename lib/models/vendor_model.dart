class VendorModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final String? phone;
  final bool isOpen;
  final int currentQueueLength;
  final int avgServiceMinutes;

  VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    this.phone,
    required this.isOpen,
    required this.currentQueueLength,
    required this.avgServiceMinutes,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      isOpen: json['is_open'] as bool,
      currentQueueLength: json['current_queue_length'] as int? ?? 0,
      avgServiceMinutes: json['avg_service_minutes'] as int? ?? 5,
    );
  }

  int get estimatedWaitMinutes => currentQueueLength * avgServiceMinutes;
}
