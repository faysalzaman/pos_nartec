import 'package:pos/model/sales/sales_model.dart';
import 'package:pos/model/sales/sales_model_by_id.dart';
import 'package:pos/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SalesController {
  // get sales
  static Future<SalesModel> getSalesOrders({
    required int page,
    required int limit,
    String? search,
    String? orderType,
    String? chef,
    String? taker,
    String? cashier,
    String? sortBy = "updatedAt",
    String? sortOrder = "-1",
  }) async {
    final url =
        Uri.parse("${AppUrl.baseUrl}/api/orders/sales?page=$page&limit=$limit");

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return SalesModel.fromJson(data['data']);
    } else {
      throw Exception(data['message']);
    }
  }

  // sales by id
  static Future<SalesModelById> getSalesOrdersById({required String id}) async {
    final url = Uri.parse("${AppUrl.baseUrl}/api/orders/$id");

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SalesModelById.fromJson(data);
    } else {
      throw Exception(data['message']);
    }
  }

  // delete sales by id
  static Future deleteSalesOrderById(String id) async {
    final url = Uri.parse("${AppUrl.baseUrl}/api/orders/$id");

    final response = await http.delete(url);
    final data = jsonDecode(response.body);

    print(data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message']);
    }
  }
}
