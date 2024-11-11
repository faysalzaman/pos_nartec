import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:pos/screens/main_dashboard/sales/sales_screen.dart';
import 'package:pos/utils/app_colors.dart';

class SalesDetailScreen extends StatelessWidget {
  final String orderNo;
  final OrderData data;

  const SalesDetailScreen({
    super.key,
    required this.orderNo,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View Sale Order #$orderNo',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left panel
            Expanded(
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barcode section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 300,
                              height: 100,
                              child: BarcodeWidget(
                                data: orderNo,
                                barcode: Barcode.code128(),
                                drawText: false,
                                color: Colors.black,
                              ),
                            ),
                            Text(orderNo),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow('Created at', data.completedAt.toString()),
                      _buildInfoRow('Customer', data.customer),
                      _buildInfoRow('Order Type', data.orderType),
                      _buildInfoRow('Location', data.customer),
                      _buildInfoRow('Kitchen Status', 'Ready',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ready',
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                      _buildInfoRow('Chef', data.customer),
                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Progress',
                            style: TextStyle(color: Colors.grey),
                          ),
                          LinearProgressIndicator(
                            value: 4.0,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          'Last updated at', data.completedAt.toString()),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right panel
            Expanded(
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderItem('Cheeseburger', 9.99, 1),
                      const Divider(),
                      _buildTotalRow('Items:', '1'),
                      _buildTotalRow('Subtotal:', '\$9.99'),
                      _buildTotalRow('Discount', '-\$0.00'),
                      _buildTotalRow('Net Amount:', '\$9.99'),
                      _buildTotalRow('Grand Total', '\$9.99',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildPaymentInfo('Payment Method:', 'Not specified'),
                      _buildPaymentInfo('Payment Status:', 'Pending',
                          statusColor: Colors.orange),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          trailing ?? Text(value),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String name, double price, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text('\$${price.toStringAsFixed(2)} x $quantity'),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value,
      {TextStyle? style = const TextStyle()}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(String label, String status,
      {Color statusColor = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor),
          ),
        ),
      ],
    );
  }
}
