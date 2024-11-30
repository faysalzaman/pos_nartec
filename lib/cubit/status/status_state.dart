import 'package:pos/model/order/status_model.dart';

abstract class StatusState {}

class StatusInitial extends StatusState {}

class StatusLoading extends StatusState {}

class StatusSuccess extends StatusState {
  final List<StatusModel> status;

  StatusSuccess({required this.status});
}

class StatusError extends StatusState {
  final String message;

  StatusError({required this.message});
}
