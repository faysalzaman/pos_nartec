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
