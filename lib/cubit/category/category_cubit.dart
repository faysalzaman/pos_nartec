import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/controller/category/category_controller.dart';
import 'package:pos/cubit/category/category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(CategoryInitial());

  Future<void> getCategories({
    required int page,
    required int limit,
    String? search,
  }) async {
    emit(CategoryLoading());

    try {
      final response = await CategoryController.getCategories(
        page: page,
        limit: limit,
        search: search ?? "",
      );
      emit(CategorySuccess(response: response));
    } catch (e) {
      log(e.toString());
      emit(CategoryError(message: e.toString().replaceAll("Exception:", "")));
    }
  }

  Future<void> deleteCategory(String id) async {
    emit(CategoryDeleteLoading());

    try {
      await CategoryController.deleteCategory(id);
      emit(CategoryDeleteSuccess());
    } catch (e) {
      emit(CategoryDeleteError(
          message: e.toString().replaceAll("Exception:", "")));
    }
  }

  Future<void> createCategory(String name, String imagePath) async {
    emit(CreateCategoryLoading());

    try {
      await CategoryController.createCategory(name, imagePath);
      emit(CreateCategorySuccess());
    } catch (e) {
      emit(CreateCategoryError(
          message: e.toString().replaceAll("Exception:", "")));
    }
  }

  Future<void> updateCategory(String id, String name, String imagePath) async {
    emit(UpdateCategoryLoading());

    try {
      await CategoryController.updateCategory(id, name, imagePath);
      emit(UpdateCategorySuccess());
    } catch (e) {
      emit(UpdateCategoryError(
          message: e.toString().replaceAll("Exception:", "")));
    }
  }
}
