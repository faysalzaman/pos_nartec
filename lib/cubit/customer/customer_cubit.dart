import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/controller/customer/customer_controller.dart';
import 'package:pos/cubit/customer/customer_state.dart';
import 'package:pos/model/customer/customer_model.dart';

class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit() : super(CustomerInitial());

  static CustomerCubit get(BuildContext context) => BlocProvider.of(context);

  List<CustomerModel> customerList = [];
  CustomerModel? selectedCustomer;

  Future<void> searchCustomer(String search) async {
    emit(CustomerLoading());

    try {
      customerList = await CustomerController.searchCustomer(search);
      emit(CustomerSuccess(response: customerList));
    } catch (e) {
      log(e.toString());
      emit(CustomerError(message: e.toString().replaceAll("Exception:", "")));
    }
  }
}
