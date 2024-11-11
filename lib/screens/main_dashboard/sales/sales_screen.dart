import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:pos/screens/main_dashboard/sales/sales_detail_screen.dart';
import 'package:pos/utils/app_colors.dart';
import 'dart:math' show min;

class OrderData {
  final String orderNo;
  final String customer;
  final int items;
  final double total;
  final String orderType;
  final String tableInfo;
  final String kitchenStatus;
  final String paymentStatus;
  final DateTime bookedAt;
  final DateTime? preparedAt;
  final DateTime? completedAt;

  OrderData({
    required this.orderNo,
    required this.customer,
    required this.items,
    required this.total,
    required this.orderType,
    required this.tableInfo,
    required this.kitchenStatus,
    required this.paymentStatus,
    required this.bookedAt,
    this.preparedAt,
    this.completedAt,
  });
}

class SalesOrdersScreen extends StatefulWidget {
  const SalesOrdersScreen({super.key});

  @override
  State<SalesOrdersScreen> createState() => _SalesOrdersScreenState();
}

class _SalesOrdersScreenState extends State<SalesOrdersScreen> {
  List<OrderData> orders = [];
  List<OrderData> filteredOrders = [];
  int _currentPage = 1;
  final int _rowsPerPage = 10;

  String byOrderType = "Delivery";
  List<String> orderType = ["Delivery", "Dine-in", "Take-away"];

  String takerBy = "Taker 1";
  List<String> taker = ["Taker 1", "Taker 2", "Taker 3"];

  String chefBy = "Chef 1";
  List<String> chef = ["Chef 1", "Chef 2", "Chef 3"];

  String checkoutBy = "Cashier 1";
  List<String> cashier = ["Cashier 1", "Cashier 2", "Cashier 3"];

  String sortBy = "Updated at";
  List<String> sortOptions = [
    "Updated at",
    "Created at",
    "Order number",
    "Customer name"
  ];

  String pageLimit = "10";
  List<String> pageLimitOptions = ['10', '25', '50', '100'];

  bool _showFilterPanel = false;

  // Calculate total pages
  int get _totalPages => (filteredOrders.length / _rowsPerPage).ceil();

  // Get paginated data
  List<OrderData> get _paginatedOrders {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = min(startIndex + _rowsPerPage, filteredOrders.length);
    return filteredOrders.sublist(startIndex, endIndex);
  }

  @override
  void initState() {
    super.initState();
    // Add dummy data
    orders = [
      OrderData(
        orderNo: 'ORD001',
        customer: 'John Doe',
        items: 3,
        total: 45.99,
        orderType: 'Delivery',
        tableInfo: 'N/A',
        kitchenStatus: 'Preparing',
        paymentStatus: 'Paid',
        bookedAt: DateTime.now(),
      ),
      OrderData(
        orderNo: 'ORD002',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD003',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD001',
        customer: 'John Doe',
        items: 3,
        total: 45.99,
        orderType: 'Delivery',
        tableInfo: 'N/A',
        kitchenStatus: 'Preparing',
        paymentStatus: 'Paid',
        bookedAt: DateTime.now(),
      ),
      OrderData(
        orderNo: 'ORD002',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD003',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD001',
        customer: 'John Doe',
        items: 3,
        total: 45.99,
        orderType: 'Delivery',
        tableInfo: 'N/A',
        kitchenStatus: 'Preparing',
        paymentStatus: 'Paid',
        bookedAt: DateTime.now(),
      ),
      OrderData(
        orderNo: 'ORD002',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD003',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD001',
        customer: 'John Doe',
        items: 3,
        total: 45.99,
        orderType: 'Delivery',
        tableInfo: 'N/A',
        kitchenStatus: 'Preparing',
        paymentStatus: 'Paid',
        bookedAt: DateTime.now(),
      ),
      OrderData(
        orderNo: 'ORD002',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD003',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD001',
        customer: 'John Doe',
        items: 3,
        total: 45.99,
        orderType: 'Delivery',
        tableInfo: 'N/A',
        kitchenStatus: 'Preparing',
        paymentStatus: 'Paid',
        bookedAt: DateTime.now(),
      ),
      OrderData(
        orderNo: 'ORD002',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderData(
        orderNo: 'ORD003',
        customer: 'Jane Smith',
        items: 2,
        total: 29.99,
        orderType: 'Dine-in',
        tableInfo: 'Table 4',
        kitchenStatus: 'Completed',
        paymentStatus: 'Pending',
        bookedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
    filteredOrders = orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredOrders = orders
                                .where((order) => order.orderNo
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilterPanel = !_showFilterPanel;
                        });
                      },
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          filteredOrders = orders;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              // Full-Screen Data Table
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      showCheckboxColumn: false,
                      headingRowColor:
                          WidgetStateProperty.all(AppColors.primary),
                      headingTextStyle: const TextStyle(color: Colors.white),
                      dataRowMaxHeight: 80,
                      columns: const [
                        DataColumn(label: Text('ORDER NO')),
                        DataColumn(label: Text('CUSTOMER')),
                        DataColumn(label: Text('ITEMS')),
                        DataColumn(label: Text('TOTAL')),
                        DataColumn(label: Text('ORDER TYPE')),
                        DataColumn(label: Text('TABLE INFO')),
                        DataColumn(label: Text('KITCHEN STATUS')),
                        DataColumn(label: Text('PAYMENT')),
                        DataColumn(label: Text('BOOKED AT')),
                      ],
                      rows: _paginatedOrders.map((order) {
                        return DataRow(
                          onSelectChanged: (isSelected) {
                            if (isSelected != null && isSelected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SalesDetailScreen(
                                    orderNo: order.orderNo,
                                    data: order,
                                  ),
                                ),
                              );
                            }
                          },
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BarcodeWidget(
                                    barcode: Barcode.code128(),
                                    data: order.orderNo,
                                    width: 80,
                                    height: 30,
                                    drawText: false,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(order.orderNo),
                                ],
                              ),
                            ),
                            DataCell(Text(order.customer)),
                            DataCell(Text(order.items.toString())),
                            DataCell(
                                Text('\$${order.total.toStringAsFixed(2)}')),
                            DataCell(Text(order.orderType)),
                            DataCell(Text(order.tableInfo)),
                            DataCell(Text(order.kitchenStatus)),
                            DataCell(Text(order.paymentStatus)),
                            DataCell(Text(order.bookedAt.toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // Add pagination controls
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // the current page items / total items like 3/300
                    Text(
                      '${_currentPage * 10} / ${_totalPages * 10}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text('${filteredOrders.length} Total Items'),
                    Text('Page $_currentPage of $_totalPages'),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                          child: const Text(
                            'Previous',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _currentPage < _totalPages
                              ? () => setState(() => _currentPage++)
                              : null,
                          child: const Text(
                            'Next',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Add Filter Panel
          if (_showFilterPanel)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 300,
              child: Material(
                elevation: 8,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _showFilterPanel = false;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search
                        const SizedBox(height: 16),
                        const Text('By Order Type'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: byOrderType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_shipping),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: orderType.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              byOrderType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('By Taker'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: takerBy,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: taker.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              takerBy = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('By Chef'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: chefBy,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.restaurant),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: chef.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              chefBy = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('By Cashier'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: checkoutBy,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.point_of_sale),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: cashier.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              checkoutBy = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Sort By'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: sortBy,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.sort),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: sortOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              sortBy = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Page Limit'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: pageLimit,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.format_list_numbered),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: pageLimitOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              pageLimit = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              setState(() {
                                _showFilterPanel = false;
                              });
                            },
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
