import 'package:pos/model/customer/customer_model.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerSuccess extends CustomerState {
  final List<CustomerModel> response;

  CustomerSuccess({required this.response});
}

class CustomerError extends CustomerState {
  final String message;

  CustomerError({required this.message});
}