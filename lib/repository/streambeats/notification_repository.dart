import 'package:streambeats/services/db/global_db.dart';
import 'package:streambeats/services/db/dao/notification_dao.dart';

class NotificationRepository {
  final NotificationDAO _notificationDao;

  const NotificationRepository(this._notificationDao);

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    String? url,
    String? payload,
    bool unique = false,
  }) =>
      _notificationDao.putNotification(
        title: title,
        body: body,
        type: type,
        url: url,
        payload: payload,
        unique: unique,
      );

  Future<List<NotificationsDB>> getNotifications() =>
      _notificationDao.getNotifications();

  Future<void> clearAll() => _notificationDao.clearNotifications();

  Future<Stream<void>> watchNotifications() =>
      _notificationDao.watchNotification();
}