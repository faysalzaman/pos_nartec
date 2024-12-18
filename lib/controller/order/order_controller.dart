import 'package:pos/model/order/orders_model.dart';
import 'package:pos/model/order/status_model.dart';
import 'package:pos/utils/app_preferences.dart';
import 'package:pos/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderController {
  static Future<List<StatusModel>> getOrderByStatus({
    required String status,
  }) async {
    final token = AppPreferences.getToken();
    final url = Uri.parse("${AppUrl.baseUrl}/api/orders/status?status=$status");

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      final allData = data['orders'] as List;
      return allData.map((e) => StatusModel.fromJson(e)).toList();
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<void> submitOrder(
    Map<String, dynamic> instructions,
    List<Map<String, dynamic>> menuItems,
    Map<String, dynamic> orderDetails,
    String orderType,
  ) async {
    final token = AppPreferences.getToken();

    final url = Uri.parse("${AppUrl.baseUrl}/api/orders");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final formattedInstructions = instructions.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final formattedOrderDetails = orderDetails.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final body = {
      "instructions": formattedInstructions,
      "lineItems": menuItems.map((item) {
        final Map<String, dynamic> lineItem = {
          "menuItemId": item["menuItemId"].toString(),
          "quantity": item["quantity"],
        };

        if (item.containsKey("modifiers")) {
          // Expect modifiers to be a List of Maps containing modifier ID and quantity
          final modifiers = (item["modifiers"] as List)
              .where((modifier) => modifier != null)
              .map((modifier) => {
                    "modifier": modifier["modifierId"].toString(),
                    "quantity": modifier["quantity"]
                  })
              .toList();

          if (modifiers.isNotEmpty) {
            lineItem["modifiers"] = modifiers;
          }
        }

        return lineItem;
      }).toList(),
      "orderDetails": formattedOrderDetails,
    };

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success case
        return;
      } else if (responseData['error']?.contains('transaction')) {
        // Handle transaction mismatch error
        throw Exception(
            'Transaction synchronization error: ${responseData['error']}');
      } else {
        throw Exception(responseData['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('Error submitting order: $e');
      throw Exception('Failed to submit order: $e');
    }
  }

  // get order by id
  static Future<OrdersModel> getOrderById(String id) async {
    final token = AppPreferences.getToken();
    final url = Uri.parse("${AppUrl.baseUrl}/api/orders/$id");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['order'];
      return OrdersModel.fromJson(data);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  static Future<void> deleteOrder(String id) async {
    final token = AppPreferences.getToken();
    final url = Uri.parse("${AppUrl.baseUrl}/api/orders/$id");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // delete order item
  static Future<void> deleteOrdersItemById(
      String id, String orderItemId) async {
    final token = AppPreferences.getToken();
    final url =
        Uri.parse("${AppUrl.baseUrl}/api/orders/$id/items/$orderItemId");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
