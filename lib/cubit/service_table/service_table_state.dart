import 'package:pos/model/pickup/pickup_model.dart';
import 'package:pos/model/service_table/service_table_model.dart';

abstract class ServiceTableState {}

class ServiceTableInitial extends ServiceTableState {}

class ServiceTableLoading extends ServiceTableState {}

class ServiceTableSuccess extends ServiceTableState {
  final List<ServiceTableModel> response;

  ServiceTableSuccess({required this.response});
}

class ServiceTableError extends ServiceTableState {
  final String message;

  ServiceTableError({required this.message});
}

class PickupSuccess extends ServiceTableState {
  final List<PickupModel> response;

  PickupSuccess({required this.response});
}

class PickupError extends ServiceTableState {
  final String message;

  PickupError({required this.message});
}
