import 'package:dio/dio.dart';
import '../api_client.dart';
import '../token_storage.dart';
import '../../../shared/models/app_models.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<AppUser> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final data = res.data['data'];
    await TokenStorage.saveTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
    return AppUser.fromJson(data['user']);
  }

  Future<AppUser> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String businessName,
    required String businessType,
    required String businessAddress,
  }) async {
    final res = await _dio.post('/auth/register/customer', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'businessName': businessName,
      'businessType': businessType,
      'businessAddress': businessAddress,
    });
    final data = res.data['data'];
    await TokenStorage.saveTokens(accessToken: data['access_token'], refreshToken: data['refresh_token']);
    return AppUser.fromJson(data['user']);
  }

  Future<AppUser> registerFarmer({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String farmName,
    required double landArea,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'farmName': farmName,
      'landArea': landArea,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final res = await _dio.post('/auth/register/farmer', data: formData);
    final data = res.data['data'];
    await TokenStorage.saveTokens(accessToken: data['access_token'], refreshToken: data['refresh_token']);
    return AppUser.fromJson(data['user']);
  }

  Future<AppUser> me() async {
    final res = await _dio.get('/auth/me');
    return AppUser.fromJson(res.data['data']);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await TokenStorage.clear();
    }
  }
}
