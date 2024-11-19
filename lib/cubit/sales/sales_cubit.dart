import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/controller/sales/sales_controller.dart';
import 'package:pos/cubit/sales/sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  SalesCubit() : super(SalesInitial());

  Future<void> getSalesOrders({
    required int page,
    required int limit,
    String? search,
    String? orderType,
    String? chef,
    String? taker,
    String? cashier,
    String? sortBy = "updatedAt",
    String? sortOrder = "-1",
  }) async {
    emit(SalesLoading());

    try {
      final response = await SalesController.getSalesOrders(
        page: page,
        limit: limit,
        search: search ?? "",
        orderType: orderType ?? "",
        chef: chef ?? "",
        taker: taker ?? "",
        cashier: cashier ?? "",
      );
      emit(SalesSuccess(response: response));
    } catch (e) {
      log(e.toString());
      emit(SalesError(message: e.toString().replaceAll("Exception:", "")));
    }
  }

  // get sales by id
  Future<void> getSalesOrdersById({required String id}) async {
    emit(SalesLoading());

    try {
      final response = await SalesController.getSalesOrdersById(id: id);
      emit(SalesSuccessById(response: response));
    } catch (e) {
      emit(SalesError(message: e.toString().replaceAll("Exception:", "")));
    }
  }

  // Delete sales by id
  Future<void> deleteSalesOrdersById({required String id}) async {
    emit(SalesDeletedLoading());

    try {
      await SalesController.deleteSalesOrderById(id);
      emit(SalesDeletedById());
    } catch (e) {
      emit(SalesError(message: e.toString().replaceAll("Exception:", "")));
    }
  }
}
