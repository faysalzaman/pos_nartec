import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos/cubit/sales/sales_cubit.dart';
import 'package:pos/cubit/sales/sales_state.dart';
import 'package:pos/model/sales/sales_model_by_id.dart';
import 'package:pos/utils/app_colors.dart';

// delivery = address + phone + all details
// dining = table + capacity
// takeaway = place.

class SalesDetailScreen extends StatefulWidget {
  final String id;
  final String orderType;

  const SalesDetailScreen({
    super.key,
    required this.id,
    required this.orderType,
  });

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SalesCubit>().getSalesOrdersById(id: widget.id);
  }

  SalesModelById? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'View Sale Order   ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              '#${widget.id}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
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
      body: BlocConsumer<SalesCubit, SalesState>(
        listener: (context, state) {
          if (state is SalesSuccessById) {
            setState(() {
              data = state.response;
            });
          }
          if (state is SalesError) {
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
            return const Center(
                child: SpinKitFadingCircle(color: AppColors.primary));
          }
          return Padding(
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
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: 300,
                                  height: 100,
                                  child: BarcodeWidget(
                                    data: data?.order.tracking ?? '',
                                    barcode: Barcode.code128(),
                                    drawText: false,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(data?.order.tracking ?? ''),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow('Created at',
                              data?.order.createdAt.toString() ?? ''),
                          _buildInfoRow(
                              'Customer', data?.order.customer!.name ?? ''),
                          _buildInfoRow('Order Type',
                              data?.order.orderDetails!.orderType ?? ''),
                          _buildInfoRow(
                              widget.orderType == 'delivery'
                                  ? 'Delivery Address'
                                  : widget.orderType == 'dining'
                                      ? 'Table'
                                      : 'Pickup Location',
                              widget.orderType == 'delivery'
                                  ? "${data?.order.orderDetails!.location!.details!.address ?? ""}\n${data?.order.orderDetails!.location!.details!.phone ?? ""}\n${data?.order.orderDetails!.location!.details!.capacity ?? ""}"
                                  : widget.orderType == 'dining'
                                      ? data?.order.orderDetails!.location!
                                              .details!.tableName! ??
                                          ''
                                      : data?.order.orderDetails!.location!
                                              .details!.address ??
                                          ''),
                          _buildInfoRow(
                              'Kitchen Status',
                              data?.order.orderDetails!.location!.details!
                                      .status ??
                                  '',
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
                          _buildInfoRow(
                              'Chef', data?.order.kitchen!.chef ?? ''),
                          // Progress bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Order Progress",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "${data?.order.progress.toString()}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              LinearProgressIndicator(
                                value: double.parse(
                                        data?.order.progress.toString() ??
                                            '0') /
                                    100,
                                backgroundColor: Colors.grey.shade200,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Last updated at',
                              data!.order.updatedAt.toString()),
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
                          ListView.builder(
                            itemCount: data?.order.orderDetails!.items!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return _buildOrderItem(
                                data?.order.orderDetails!.items![index]
                                        .menuItem!.name ??
                                    "",
                                data?.order.orderDetails!.items![index]
                                        .menuItem!.price ??
                                    0,
                                data?.order.orderDetails!.items![index]
                                        .quantity ??
                                    0,
                                data?.order.orderDetails!.items![index].price ??
                                    0,
                              );
                            },
                          ),
                          _buildTotalRow(
                              'Items:',
                              data?.order.orderDetails!.items!.length
                                      .toString() ??
                                  ''),
                          _buildTotalRow('Subtotal:',
                              'AED ${data?.order.financial!.subtotal ?? ""}'),
                          _buildTotalRow('Discount',
                              'AED ${data?.order.financial!.discount ?? ""}'),
                          _buildTotalRow('Net Amount:',
                              'AED ${data?.order.financial!.netAmount ?? ""}'),
                          _buildTotalRow('Grand Total',
                              'AED ${data?.order.financial!.grandTotal ?? ""}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          29.height,
                          _buildPaymentInfo('Payment Method:',
                              data?.order.payment!.method ?? ""),
                          10.height,
                          _buildPaymentInfo('Payment Status:',
                              data?.order.payment!.status ?? ""),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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

  Widget _buildOrderItem(
    String name,
    double price,
    int quantity,
    double totalPrice,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name),
              Text('AED ${price.toStringAsFixed(2)} x $quantity'),
            ],
          ),
          10.height,
          Text("AED ${totalPrice.toStringAsFixed(2)}"),
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
            color: AppColors.primary.withOpacity(0.4),
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
