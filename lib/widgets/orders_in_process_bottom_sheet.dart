import 'package:flutter/material.dart';
import 'package:pos/model/order/status_model.dart';
import 'package:pos/utils/app_colors.dart';

class OrdersInProcessBottomSheet extends StatelessWidget {
  const OrdersInProcessBottomSheet({
    super.key,
    required this.pendingList,
    required this.preparingList,
    required this.readyList,
  });

  final List<StatusModel> pendingList;
  final List<StatusModel> preparingList;
  final List<StatusModel> readyList;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Orders in Process',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                icon: const Icon(Icons.access_time, color: Colors.orange),
                text: 'Pending (${pendingList.length})',
              ),
              Tab(
                icon: Icon(Icons.kitchen, color: Colors.pink[200]),
                text: 'Preparing (${preparingList.length})',
              ),
              Tab(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                text: 'Ready (${readyList.length})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(pendingList),
            _buildOrderList(preparingList),
            _buildOrderList(readyList),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<StatusModel> orders) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          child: ListTile(
            title: Text('Order #${order.tracking}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                'Type: ${order.orderType}\nCustomer: ${order.customer}\nCreated At: ${order.createdAt}\nUpdated At: ${order.updatedAt}',
                style: TextStyle(color: Colors.grey.shade600)),
            trailing: Text('Progress: ${order.progress}%',
                style: const TextStyle(color: Colors.green)),
          ),
        );
      },
    );
  }
}
