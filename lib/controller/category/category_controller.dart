// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:pos/model/category/category_model.dart';
import 'package:pos/utils/app_preferences.dart';
import 'package:pos/utils/app_url.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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

  // create category
  static Future<void> createCategory(String name, String imagePath) async {
    final token = AppPreferences.getToken();
    final url = Uri.parse('${AppUrl.baseUrl}/api/categories');

    // Create multipart request
    final request = http.MultipartRequest('POST', url);

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add text field
    request.fields['name'] = name;

    // Add image file
    request.files.add(await http.MultipartFile.fromPath(
      'categoryImage',
      imagePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("data: $data");
    } else {
      throw Exception(data['message'] ?? 'Failed to create category');
    }
  }

  // update category
  static Future<void> updateCategory(
      String id, String name, String imagePath) async {
    final token = AppPreferences.getToken();
    final url = Uri.parse('${AppUrl.baseUrl}/api/categories/$id');

    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.files.add(await http.MultipartFile.fromPath(
      'categoryImage',
      imagePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("data: $data");
    } else {
      throw Exception(data['message'] ?? 'Failed to update category');
    }
  }
}
