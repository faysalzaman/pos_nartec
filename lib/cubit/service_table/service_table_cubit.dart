import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/controller/service_table/service_table_controller.dart';
import 'package:pos/cubit/service_table/service_table_state.dart';
import 'package:pos/model/pickup/pickup_model.dart';
import 'package:pos/model/service_table/service_table_model.dart';

class ServiceTableCubit extends Cubit<ServiceTableState> {
  ServiceTableCubit() : super(ServiceTableInitial());

  static ServiceTableCubit get(context) => BlocProvider.of(context);

  List<ServiceTableModel> serviceTables = [];
  ServiceTableModel? selectedServiceTable;

  List<PickupModel> pickupPoints = [];
  PickupModel? selectedPickupPoint;

  Future<void> getServiceTables() async {
    emit(ServiceTableLoading());

    try {
      serviceTables = await ServiceTableController.getServiceTables();
      emit(ServiceTableSuccess(response: serviceTables));
    } catch (e) {
      log(e.toString());
      emit(ServiceTableError(
          message: e.toString().replaceAll("Exception:", "")));
    }
  }

  Future<void> getPickup() async {
    emit(ServiceTableLoading());

    try {
      pickupPoints = await ServiceTableController.getPickup();
      emit(PickupSuccess(response: pickupPoints));
    } catch (e) {
      log(e.toString());
      emit(PickupError(message: e.toString().replaceAll("Exception:", "")));
    }
  }
}
