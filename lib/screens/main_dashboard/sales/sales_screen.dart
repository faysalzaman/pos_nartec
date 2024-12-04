import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pos/cubit/sales/sales_cubit.dart';
import 'package:pos/cubit/sales/sales_state.dart';
import 'package:pos/model/sales/sales_model.dart';
import 'package:pos/screens/main_dashboard/sales/sales_detail_screen.dart';
import 'package:pos/utils/app_colors.dart';
import 'package:pos/utils/app_navigator.dart';

class SalesOrdersScreen extends StatefulWidget {
  const SalesOrdersScreen({super.key});

  @override
  State<SalesOrdersScreen> createState() => _SalesOrdersScreenState();
}

class _SalesOrdersScreenState extends State<SalesOrdersScreen> {
  SalesModel? orders;
  SalesModel? filteredOrders;

  TextEditingController searchController = TextEditingController();

  // Pagination
  int _currentPage = 1;
  final int _rowsPerPage = 10;

  // // Filters
  // String byOrderType = "Delivery";
  // List<String> orderType = ["Delivery", "Dine-in", "Take-away"];

  // String takerBy = "Taker 1";
  // List<String> taker = ["Taker 1", "Taker 2", "Taker 3"];

  // String chefBy = "Chef 1";
  // List<String> chef = ["Chef 1", "Chef 2", "Chef 3"];

  // String checkoutBy = "Cashier 1";
  // List<String> cashier = ["Cashier 1", "Cashier 2", "Cashier 3"];

  // bool _showFilterPanel = false;

  List<Orders> allOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchSalesOrders();
  }

  void _fetchSalesOrders() {
    context.read<SalesCubit>().getSalesOrders(
          page: _currentPage,
          limit: _rowsPerPage,
        );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SalesCubit, SalesState>(
        listener: (context, state) {
          if (state is SalesSuccess) {
            setState(() {
              if (_currentPage == 1) {
                allOrders = state.response.orders ?? [];
                orders = state.response;
                filteredOrders = state.response;
              } else {
                allOrders.addAll(state.response.orders ?? []);
                orders?.orders = List.from(allOrders);
                filteredOrders?.orders = List.from(allOrders);
                orders?.pagination = state.response.pagination;
                filteredOrders?.pagination = state.response.pagination;
              }
            });
          } else if (state is SalesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error!',
                  message: state.message,
                  contentType: ContentType.failure,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SalesLoading) {
            return const SpinKitFadingCircle(
              color: AppColors.primary,
              size: 24.0,
            );
          }

          return Stack(
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
                            onChanged: (value) {
                              if (value.isEmpty) {
                                // Reset to original orders when search is cleared
                                setState(() {
                                  filteredOrders = orders;
                                });
                              } else {
                                // Search by order no
                                var filtered = orders?.orders
                                        ?.where((order) => order.orderNo
                                            .toString()
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList() ??
                                    [];
                                setState(() {
                                  filteredOrders = SalesModel(
                                    orders: filtered,
                                    pagination: orders?.pagination,
                                  );
                                });
                              }
                            },
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     setState(() {
                        //       _showFilterPanel = !_showFilterPanel;
                        //     });
                        //   },
                        //   icon: const Icon(Icons.filter_list),
                        //   label: const Text('Filters'),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: AppColors.primary,
                        //     foregroundColor: Colors.white,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowColor:
                              MaterialStateProperty.all(AppColors.primary),
                          dataRowHeight: 80,
                          headingTextStyle:
                              const TextStyle(color: Colors.white),
                          columns: const [
                            DataColumn(label: Text('ORDER NO')),
                            DataColumn(label: Text('CUSTOMER')),
                            DataColumn(label: Text('ITEMS')),
                            DataColumn(label: Text('ORDERS TYPE')),
                            DataColumn(label: Text('KITCHEN STATUS')),
                            DataColumn(label: Text('PAYMENT')),
                            DataColumn(label: Text('BOOKED AT')),
                            DataColumn(label: Text('PREPARED AT')),
                            DataColumn(label: Text('COMPLETED AT')),
                          ],
                          rows: filteredOrders?.orders
                                  ?.map((order) => DataRow(
                                        onSelectChanged: (_) {
                                          AppNavigator.push(
                                            context,
                                            SalesDetailScreen(
                                              id: order.id ?? '',
                                              orderType: order.orderType ?? '',
                                              rowPerPage: _rowsPerPage,
                                              currentRow: _currentPage,
                                            ),
                                          );
                                        },
                                        cells: [
                                          DataCell(BarcodeWidget(
                                            barcode: Barcode.code128(),
                                            data: order.orderNo ?? '',
                                            width: 150,
                                            height: 50,
                                          )),
                                          DataCell(
                                            Text(order.customer?.name ??
                                                'Unknown Customer'),
                                          ),
                                          DataCell(
                                              Text(order.items.toString())),
                                          DataCell(
                                            Text(order.orderType ?? ''),
                                          ),
                                          DataCell(
                                            order.kitchenStatus == 'ready'
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: const Text(
                                                      'Ready',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    order.kitchenStatus ?? ''),
                                          ),
                                          DataCell(
                                              Text(order.paymentStatus ?? '')),
                                          DataCell(Text(order.bookedAt ?? '')),
                                          DataCell(
                                              Text(order.preparedAt ?? '')),
                                          DataCell(
                                              Text(order.completedAt ?? '')),
                                        ],
                                      ))
                                  .toList() ??
                              [],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredOrders?.orders?.length ?? 0} / ${filteredOrders?.pagination?.total ?? 0}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Page $_currentPage of ${filteredOrders?.pagination?.pages ?? 1}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _currentPage > 1
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                      _fetchSalesOrders();
                                    }
                                  : null,
                              child: const Text('Previous',
                                  style: TextStyle(color: AppColors.primary)),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: (_currentPage <
                                      (filteredOrders?.pagination?.pages ?? 1))
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                      _fetchSalesOrders();
                                    }
                                  : null,
                              child: const Text('Next',
                                  style: TextStyle(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // // Filter Panel
              // if (_showFilterPanel)
              //   Positioned(
              //     right: 0,
              //     top: 0,
              //     bottom: 0,
              //     width: 300,
              //     child: Material(
              //       elevation: 8,
              //       child: Container(
              //         color: Colors.white,
              //         padding: const EdgeInsets.all(16),
              //         child: SingleChildScrollView(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   const Text('Filters',
              //                       style: TextStyle(
              //                           fontSize: 20,
              //                           fontWeight: FontWeight.bold)),
              //                   IconButton(
              //                     onPressed: () {
              //                       setState(() => _showFilterPanel = false);
              //                     },
              //                     icon: const Icon(Icons.close),
              //                   ),
              //                 ],
              //               ),
              //               const SizedBox(height: 16),
              //               _buildDropdown(
              //                   'By Order Type', orderType, byOrderType,
              //                   (value) {
              //                 setState(() => byOrderType = value!);
              //               }),
              //               _buildDropdown('By Taker', taker, takerBy, (value) {
              //                 setState(() => takerBy = value!);
              //               }),
              //               _buildDropdown('By Chef', chef, chefBy, (value) {
              //                 setState(() => chefBy = value!);
              //               }),
              //               _buildDropdown('By Cashier', cashier, checkoutBy,
              //                   (value) {
              //                 setState(() => checkoutBy = value!);
              //               }),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isNotEmpty ? value : null,
          dropdownColor: Colors.white,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
