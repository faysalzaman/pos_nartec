import 'package:pos/model/category/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategorySuccess extends CategoryState {
  final CategoryModel response;

  CategorySuccess({required this.response});
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError({required this.message});
}

class CategoryDeleteLoading extends CategoryState {}

class CategoryDeleteSuccess extends CategoryState {}

class CategoryDeleteError extends CategoryState {
  final String message;

  CategoryDeleteError({required this.message});
}

class CreateCategoryLoading extends CategoryState {}

class CreateCategorySuccess extends CategoryState {}

class CreateCategoryError extends CategoryState {
  final String message;

  CreateCategoryError({required this.message});
}

class UpdateCategoryLoading extends CategoryState {}

class UpdateCategorySuccess extends CategoryState {}

class UpdateCategoryError extends CategoryState {
  final String message;

  UpdateCategoryError({required this.message});
}
