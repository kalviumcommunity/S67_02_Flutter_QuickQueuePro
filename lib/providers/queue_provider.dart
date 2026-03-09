import 'package:flutter/foundation.dart';
import '../models/queue_model.dart';
import '../models/vendor_model.dart';
import '../services/api_service.dart';

class QueueProvider extends ChangeNotifier {
  List<VendorModel> _vendors = [];
  List<QueueModel> _myQueues = [];
  List<QueueModel> _vendorQueue = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VendorModel> get vendors => _vendors;
  List<QueueModel> get myQueues => _myQueues;
  List<QueueModel> get vendorQueue => _vendorQueue;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVendors() async {
    _setLoading(true);
    try {
      _vendors = await ApiService.instance.getVendors();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyQueue() async {
    _setLoading(true);
    try {
      _myQueues = await ApiService.instance.getMyQueue();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchVendorQueue(String vendorId) async {
    _setLoading(true);
    try {
      _vendorQueue = await ApiService.instance.getVendorQueue(vendorId);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> joinQueue(String vendorId) async {
    _setLoading(true);
    try {
      final token = await ApiService.instance.joinQueue(vendorId);
      _myQueues = [token, ..._myQueues];
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelQueue(String queueId) async {
    _setLoading(true);
    try {
      await ApiService.instance.cancelQueue(queueId);
      _myQueues.removeWhere((q) => q.id == queueId);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> serveNext(String vendorId) async {
    _setLoading(true);
    try {
      await ApiService.instance.serveNext(vendorId);
      await fetchVendorQueue(vendorId);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
