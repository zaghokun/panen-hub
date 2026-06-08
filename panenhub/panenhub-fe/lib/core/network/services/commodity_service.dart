import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../../shared/models/app_models.dart';

class CommodityService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Commodity>> list({String? search, String? category, int page = 1}) async {
    final res = await _dio.get('/commodities', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category.isNotEmpty) 'category': category,
      'page': page,
    });
    final items = res.data['data'] as List;
    return items.map((e) => Commodity.fromJson(e)).toList();
  }

  Future<Commodity> detail(String id) async {
    final res = await _dio.get('/commodities/$id');
    return Commodity.fromJson(res.data['data']);
  }

  Future<List<Commodity>> farmerList() async {
    final res = await _dio.get('/farmer/commodities');
    final items = res.data['data'] as List;
    return items.map((e) => Commodity.fromJson(e)).toList();
  }

  Future<Commodity> create({
    required String name,
    required String category,
    String? description,
    required int pricePerKg,
    required double availableQuotaKg,
    required String estimatedHarvestDate,
    required String location,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'category': category,
      if (description != null) 'description': description,
      'pricePerKg': pricePerKg,
      'availableQuotaKg': availableQuotaKg,
      'estimatedHarvestDate': estimatedHarvestDate,
      'location': location,
    });
    final res = await _dio.post('/farmer/commodities', data: formData);
    return Commodity.fromJson(res.data['data']);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/farmer/commodities/$id');
  }
}
