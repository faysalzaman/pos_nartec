import 'package:pos/model/category/category_model.dart';
import 'package:pos/utils/app_url.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryController {
  static Future<CategoryModel> getCategories({
    required int page,
    required int limit,
    String search = "",
  }) async {
    final url = Uri.parse(
        "${AppUrl.baseUrl}/api/categories?page=$page&limit=$limit&search=$search");

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CategoryModel.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Unknown error');
    }
  }
}
