import 'package:pos/model/customer/customer_model.dart';
import 'package:pos/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerController {
  static Future<List<CustomerModel>> searchCustomer(String search) async {
    final url =
        Uri.parse("${AppUrl.baseUrl}/api/customers/search?search=$search");

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => CustomerModel.fromJson(e)).toList();
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<void> addCustomer({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    final url = Uri.parse("${AppUrl.baseUrl}/api/customers");

    final body = {
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
    };

    final headers = {
      "Content-Type": "application/json",
    };

    final response =
        await http.post(url, body: jsonEncode(body), headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message']);
    }
  }
}
