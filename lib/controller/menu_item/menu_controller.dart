import 'package:pos/model/menu_item/menu_item_model.dart';
import 'package:pos/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuItemController {
  static Future<MenuItemResponse> getMenuItems({
    required int page,
    required int limit,
    String search = "",
    String category = "",
  }) async {
    final url = Uri.parse(
        "${AppUrl.baseUrl}/api/menu-items?page=$page&limit=$limit&search=$search&category=$category");

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MenuItemResponse.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Unknown error');
    }
  }
}
