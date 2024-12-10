import 'package:pos/model/pickup/pickup_model.dart';
import 'package:pos/model/service_table/service_table_model.dart';
import 'package:pos/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceTableController {
  static Future<List<ServiceTableModel>> getServiceTables() async {
    const url = '${AppUrl.baseUrl}/api/service-tables';
    final response = await http.get(Uri.parse(url));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body)["serviceTables"] as List;
      return jsonData.map((item) => ServiceTableModel.fromJson(item)).toList();
    } else {
      throw Exception(jsonData['message']);
    }
  }

  static Future<List<PickupModel>> getPickup() async {
    const url = '${AppUrl.baseUrl}/api/pickup-points';
    final response = await http.get(Uri.parse(url));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body)['pickupPoints'] as List;
      return jsonData.map((item) => PickupModel.fromJson(item)).toList();
    } else {
      throw Exception(jsonData['message']);
    }
  }
}
