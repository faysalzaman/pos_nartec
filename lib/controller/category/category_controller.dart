import 'package:pos/model/category/category_model.dart';
import 'package:pos/utils/app_preferences.dart';
import 'package:pos/utils/app_url.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryController {
  static Future<CategoryModel> getCategories({
    required int page,
    required int limit,
    String search = "",
  }) async {
    final token = AppPreferences.getToken();
    final url = Uri.parse(
        "${AppUrl.baseUrl}/api/categories?page=$page&limit=$limit&search=$search");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CategoryModel.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Unknown error');
    }
  }

  // delete category
  static Future<void> deleteCategory(String id) async {
    final token = AppPreferences.getToken();
    final url = Uri.parse('${AppUrl.baseUrl}/api/categories/$id');

    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    var data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("data: $data");
    } else {
      throw Exception(data['message'] ?? 'Failed to delete category');
    }
  }
}
