import '../models/notification_model.dart';
import 'api_service.dart';

/// 通知服务：获取通知列表 API
class NotificationService {
  final ApiService _api;

  NotificationService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _api.get<List<NotificationModel>>(
      path: '/notifications',
      queryParameters: {'page': page},
      fromJson: (data) {
        final items = (data['items'] as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return items;
      },
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    return [];
  }
}
