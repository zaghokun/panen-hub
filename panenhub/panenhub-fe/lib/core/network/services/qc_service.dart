import 'package:dio/dio.dart';
import '../api_client.dart';

class QcService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> submit(String orderId, {
    required String conditionStatus, // "good" | "bad"
    required String quantityStatus,  // "complete" | "less"
    String? qualityNotes,
  }) async {
    final formData = FormData.fromMap({
      'conditionStatus': conditionStatus,
      'quantityStatus': quantityStatus,
      if (qualityNotes != null) 'qualityNotes': qualityNotes,
    });
    final res = await _dio.post('/orders/$orderId/qc', data: formData);
    return res.data['data'] as Map<String, dynamic>;
  }
}
