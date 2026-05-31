import '../api_client.dart';
import '../../../shared/models/app_models.dart';

class ReviewService {
  final _dio = ApiClient.instance.dio;

  Future<Review> create(String orderId, {
    required int rating,
    required String comment,
    int? qualityRating,
    int? deliveryRating,
  }) async {
    final res = await _dio.post('/orders/$orderId/reviews', data: {
      'rating': rating,
      'comment': comment,
      if (qualityRating != null) 'qualityRating': qualityRating,
      if (deliveryRating != null) 'deliveryRating': deliveryRating,
    });
    return Review.fromJson(res.data['data']);
  }
}
