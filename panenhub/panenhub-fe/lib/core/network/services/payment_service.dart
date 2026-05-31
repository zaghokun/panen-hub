import '../api_client.dart';
import '../../../shared/models/app_models.dart';

class PaymentService {
  final _dio = ApiClient.instance.dio;

  Future<Payment> create(String orderId, {String method = 'bank_transfer'}) async {
    final res = await _dio.post('/orders/$orderId/payments', data: {'method': method});
    return Payment.fromJson(res.data['data']);
  }

  Future<Payment> getStatus(String orderId) async {
    final res = await _dio.get('/orders/$orderId/payments/status');
    return Payment.fromJson(res.data['data']);
  }
}
