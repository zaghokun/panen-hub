import '../api_client.dart';
import '../../../shared/models/app_models.dart';

class NotificationService {
  final _dio = ApiClient.instance.dio;

  Future<List<AppNotification>> list({bool? isRead, int page = 1}) async {
    final res = await _dio.get('/notifications', queryParameters: {
      if (isRead != null) 'is_read': isRead,
      'page': page,
    });
    final items = res.data['data'] as List;
    return items.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markRead(String id) async {
    await _dio.patch('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.patch('/notifications/read-all');
  }
}
