import 'package:pos/model/order/status_model.dart';
import 'package:pos/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderController {
  static Future<List<StatusModel>> getOrderByStatus({
    required String status,
  }) async {
    final url = Uri.parse("${AppUrl.baseUrl}/api/orders/status?status=$status");

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      print(response.statusCode);
      print(response.body);

      final allData = data['orders'] as List;
      return allData.map((e) => StatusModel.fromJson(e)).toList();
    } else {
      throw Exception(data['message']);
    }
  }
}
