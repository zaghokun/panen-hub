import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../../shared/models/app_models.dart';

class DisputeService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Dispute> create(String orderId, {
    required String reason,
    required String description,
    double? quantityProblematic,
  }) async {
    final formData = FormData.fromMap({
      'reason': reason,
      'description': description,
      if (quantityProblematic != null) 'quantityProblematic': quantityProblematic,
    });
    final res = await _dio.post('/orders/$orderId/disputes', data: formData);
    return Dispute.fromJson(res.data['data']);
  }

  Future<Dispute> detail(String id) async {
    final res = await _dio.get('/disputes/$id');
    return Dispute.fromJson(res.data['data']);
  }
}
