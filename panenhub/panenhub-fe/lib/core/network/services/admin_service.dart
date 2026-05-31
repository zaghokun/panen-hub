import '../api_client.dart';
import '../../../shared/models/app_models.dart';

class AdminService {
  final _dio = ApiClient.instance.dio;

  Future<Map<String, int>> dashboard() async {
    final res = await _dio.get('/admin/dashboard');
    final data = res.data['data'] as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, v as int));
  }

  Future<void> verifyFarmer(String userId, {required String action, String? notes}) async {
    await _dio.patch('/admin/users/$userId/verify', data: {
      'action': action,
      if (notes != null) 'notes': notes,
    });
  }

  Future<List<Dispute>> listDisputes() async {
    final res = await _dio.get('/admin/disputes');
    final items = res.data['data'] as List;
    return items.map((e) => Dispute.fromJson(e)).toList();
  }

  Future<void> decideDispute(String disputeId, {
    required String decision,
    String? notes,
    int? refundAmount,
  }) async {
    await _dio.patch('/admin/disputes/$disputeId/decision', data: {
      'decision': decision,
      if (notes != null) 'notes': notes,
      if (refundAmount != null) 'refundAmount': refundAmount,
    });
  }

  Future<List<Withdrawal>> listWithdrawals() async {
    final res = await _dio.get('/admin/withdrawals');
    final items = res.data['data'] as List;
    return items.map((e) => Withdrawal.fromJson(e)).toList();
  }

  Future<void> approveWithdrawal(String id, {String? notes}) async {
    await _dio.patch('/admin/withdrawals/$id/approve', data: {
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> rejectWithdrawal(String id, {required String reason}) async {
    await _dio.patch('/admin/withdrawals/$id/reject', data: {'reason': reason});
  }

  Future<List<AppUser>> pendingVerifications() async {
    final res = await _dio.get('/admin/users/pending');
    final items = res.data['data'] as List;
    return items.map((e) => AppUser.fromJson(e)).toList();
  }
}
