// lib/cubit/order/order_state.dart

import 'package:pos/model/order/orders_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {
  final String message;
  OrderSuccess({required this.message});
}

class OrderError extends OrderState {
  final String message;
  OrderError({required this.message});
}

class OrderByIdLoading extends OrderState {}

class OrderByIdSuccess extends OrderState {
  final OrdersModel ordersModel;
  OrderByIdSuccess({required this.ordersModel});
}

class OrderByIdError extends OrderState {
  final String message;
  OrderByIdError({required this.message});
}

class OrderDeleteLoading extends OrderState {}

class OrderDeleteSuccess extends OrderState {
  final String message;
  OrderDeleteSuccess({required this.message});
}

class OrderDeleteError extends OrderState {
  final String message;
  OrderDeleteError({required this.message});
}

class OrdersItemDeleteLoading extends OrderState {}

class OrdersItemDeleteSuccess extends OrderState {
  final String message;
  OrdersItemDeleteSuccess({required this.message});
}

class OrdersItemDeleteError extends OrderState {
  final String message;
  OrdersItemDeleteError({required this.message});
}
