import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../../shared/models/app_models.dart';

class OrderService {
  final _dio = ApiClient.instance.dio;

  Future<PreOrder> create({
    required String commodityId,
    required double quantityKg,
    required String deliveryDate,
    required String deliveryAddress,
    String? notes,
  }) async {
    final res = await _dio.post('/orders', data: {
      'commodityId': commodityId,
      'quantityKg': quantityKg,
      'deliveryDate': deliveryDate,
      'deliveryAddress': deliveryAddress,
      if (notes != null) 'notes': notes,
    });
    return PreOrder.fromJson(res.data['data']);
  }

  Future<List<PreOrder>> customerList({int page = 1}) async {
    final res = await _dio.get('/orders', queryParameters: {'page': page});
    final items = res.data['data'] as List;
    return items.map((e) => PreOrder.fromJson(e)).toList();
  }

  Future<List<PreOrder>> farmerList({int page = 1}) async {
    final res = await _dio.get('/farmer/orders', queryParameters: {'page': page});
    final items = res.data['data'] as List;
    return items.map((e) => PreOrder.fromJson(e)).toList();
  }

  Future<PreOrder> detail(String id) async {
    try {
      final res = await _dio.get('/orders/$id');
      return PreOrder.fromJson(res.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        // Farmer: hit farmer-scoped endpoint instead
        final res = await _dio.get('/farmer/orders/$id');
        return PreOrder.fromJson(res.data['data']);
      }
      rethrow;
    }
  }

  Future<void> confirmReceipt(String orderId, {String? notes}) async {
    await _dio.post('/orders/$orderId/receipt-confirmation', data: {
      'is_received': true,
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> updateStatus(String orderId, {
    required String status,
    String? notes,
    String? courierName,
    String? trackingNumber,
  }) async {
    await _dio.patch('/farmer/orders/$orderId/status', data: {
      'status': status,
      if (notes != null) 'notes': notes,
      if (courierName != null) 'courierName': courierName,
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
    });
  }

  Future<List<OrderStatusHistory>> statusHistory(String orderId) async {
    try {
      final res = await _dio.get('/orders/$orderId');
      final data = res.data['data'];
      final history = data['statusHistory'] as List? ?? [];
      return history.map((e) => OrderStatusHistory.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final res = await _dio.get('/farmer/orders/$orderId');
        final data = res.data['data'];
        final history = data['statusHistory'] as List? ?? [];
        return history.map((e) => OrderStatusHistory.fromJson(e)).toList();
      }
      rethrow;
    }
  }
}
