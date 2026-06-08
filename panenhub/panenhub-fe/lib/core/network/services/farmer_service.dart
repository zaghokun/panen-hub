import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../../shared/models/app_models.dart';

class FarmerService {
  final Dio _dio = ApiClient.instance.dio;

  Future<FarmerProfile> getProfile() async {
    final res = await _dio.get('/farmer/profile');
    final data = res.data['data'];
    return FarmerProfile.fromJson(data['farmerProfile']);
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    final formData = FormData.fromMap(fields);
    await _dio.patch('/farmer/profile', data: formData);
  }

  Future<WalletSummary> getWallet() async {
    final res = await _dio.get('/farmer/wallet');
    return WalletSummary.fromJson(res.data['data']);
  }

  Future<void> requestWithdrawal({
    required int amount,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    await _dio.post('/farmer/withdrawals', data: {
      'amount': amount,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
    });
  }

  Future<List<Withdrawal>> withdrawalList() async {
    final res = await _dio.get('/farmer/withdrawals');
    final items = res.data['data'] as List;
    return items.map((e) => Withdrawal.fromJson(e)).toList();
  }
}
