import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/controller/menu_item/menu_controller.dart';
import 'package:pos/cubit/menu_item/menu_item_state.dart';

class MenuItemCubit extends Cubit<MenuItemState> {
  MenuItemCubit() : super(MenuItemInitial());

  Future<void> getMenuItems({
    required int page,
    required int limit,
    String? search,
    String? category,
  }) async {
    emit(MenuItemLoading());

    try {
      final response = await MenuItemController.getMenuItems(
        page: page,
        limit: limit,
        search: search ?? "",
        category: category ?? "",
      );
      emit(MenuItemSuccess(response: response));
    } catch (e) {
      log(e.toString());
      emit(MenuItemError(message: e.toString().replaceAll("Exception:", "")));
    }
  }
}
