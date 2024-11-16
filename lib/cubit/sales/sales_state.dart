import 'package:pos/model/sales/sales_model.dart';
import 'package:pos/model/sales/sales_model_by_id.dart';

abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesSuccess extends SalesState {
  final SalesModel response;

  SalesSuccess({required this.response});
}

class SalesSuccessById extends SalesState {
  final SalesModelById response;

  SalesSuccessById({required this.response});
}

class SalesError extends SalesState {
  final String message;

  SalesError({required this.message});
}
