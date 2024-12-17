// lib/cubit/order/order_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/cubit/order/order_state.dart';
import 'package:pos/model/order/orders_model.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  OrdersModel? ordersModel;

  static OrderCubit get(BuildContext context) =>
      BlocProvider.of<OrderCubit>(context);

  Future<void> submitOrder({
    required Map<String, dynamic> instructions,
    required List<Map<String, dynamic>> menuItems,
    required Map<String, dynamic> orderDetails,
    required String orderType,
  }) async {
    emit(OrderLoading());

    try {
      await OrderController.submitOrder(
        instructions,
        menuItems,
        orderDetails,
        orderType,
      );
      emit(OrderSuccess(message: 'Order submitted successfully'));
    } catch (e) {
      emit(OrderError(message: e.toString().replaceAll("Exception:", "")));
    }
  }

  Future<void> getOrdersById(String id) async {
    emit(OrderByIdLoading());

    try {
      var response = await OrderController.getOrderById(id);
      ordersModel = response;
      emit(OrderByIdSuccess(ordersModel: response));
    } catch (e) {
      emit(OrderByIdError(message: e.toString().replaceAll("Exception:", "")));
    }
  }

  Future<void> deleteOrder(String id) async {
    emit(OrderDeleteLoading());

    try {
      await OrderController.deleteOrder(id);
      emit(OrderDeleteSuccess(message: 'Order deleted successfully'));
    } catch (e) {
      emit(
          OrderDeleteError(message: e.toString().replaceAll("Exception:", "")));
    }
  }

  Future<void> deleteOrderItemById(String id, String orderItemId) async {
    emit(OrdersItemDeleteLoading());

    try {
      await OrderController.deleteOrdersItemById(id, orderItemId);
      emit(
          OrdersItemDeleteSuccess(message: 'Orders Item deleted successfully'));
    } catch (e) {
      emit(OrdersItemDeleteError(
          message: e.toString().replaceAll("Exception:", "")));
    }
  }
}
