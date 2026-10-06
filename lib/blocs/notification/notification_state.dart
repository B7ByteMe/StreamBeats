part of 'notification_cubit.dart';

class NotificationState extends Equatable {
  final List<AppNotification> notifications;
  const NotificationState({
    required this.notifications,
  });

  @override
  List<Object> get props => [notifications];
}

final class NotificationInitial extends NotificationState {
  NotificationInitial() : super(notifications: []);
}