import 'package:pos/model/menu_item/menu_item_model.dart';

abstract class MenuItemState {}

class MenuItemInitial extends MenuItemState {}

class MenuItemLoading extends MenuItemState {}

class MenuItemSuccess extends MenuItemState {
  final MenuItemResponse response;

  MenuItemSuccess({required this.response});
}

class MenuItemError extends MenuItemState {
  final String message;

  MenuItemError({required this.message});
}
