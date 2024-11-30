import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/controller/order/order_controller.dart';
import 'package:pos/cubit/status/status_state.dart';
import 'package:pos/model/order/status_model.dart';

class StatusCubit extends Cubit<StatusState> {
  StatusCubit() : super(StatusInitial());

  List<StatusModel> pendingStatusList = [];
  List<StatusModel> preparingStatusList = [];
  List<StatusModel> readyStatusList = [];

  static StatusCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> getOrderByStatus({required String status}) async {
    emit(StatusLoading());

    try {
      final response = await OrderController.getOrderByStatus(status: status);

      if (status == "pending") {
        pendingStatusList = response;
      } else if (status == "preparing") {
        preparingStatusList = response;
      } else if (status == "ready") {
        readyStatusList = response;
      }

      emit(StatusSuccess(status: response));
    } catch (e) {
      log(e.toString());
      emit(StatusError(message: e.toString().replaceAll("Exception:", "")));
    }
  }
}
