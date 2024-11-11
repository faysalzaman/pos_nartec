import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class StatItem {
  final String title;
  final String value;
  final Color backgroundColor;
  final IconData icon;

  StatItem({
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.icon,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<StatItem> stats = [
    StatItem(
      title: 'TOTAL ORDERS',
      value: '156',
      backgroundColor: const Color(0xFF4285F4),
      icon: Icons.assignment_outlined,
    ),
    StatItem(
      title: 'TOTAL SALES',
      value: '\$3,240',
      backgroundColor: const Color(0xFF34A853),
      icon: Icons.attach_money,
    ),
    StatItem(
      title: 'PENDING ORDERS',
      value: '8',
      backgroundColor: const Color(0xFFFBBC05),
      icon: Icons.pending_actions,
    ),
    StatItem(
      title: 'READY TO SERVE',
      value: '12',
      backgroundColor: const Color(0xFF9C27B0),
      icon: Icons.restaurant,
    ),
    StatItem(
      title: 'DINE-IN ORDERS',
      value: '45',
      backgroundColor: const Color(0xFF3F51B5),
      icon: Icons.group,
    ),
    StatItem(
      title: 'TAKEAWAY ORDERS',
      value: '32',
      backgroundColor: const Color(0xFFE91E63),
      icon: Icons.shopping_bag,
    ),
    StatItem(
      title: 'DELIVERY ORDERS',
      value: '79',
      backgroundColor: const Color(0xFFE53935),
      icon: Icons.delivery_dining,
    ),
    StatItem(
      title: 'ACTIVE TABLES',
      value: '18',
      backgroundColor: const Color(0xFFFF7043),
      icon: Icons.restaurant_menu,
    ),
  ];

  final List<SalesData> salesData = [
    SalesData(DateTime(2024, 3, 1), 1500),
    SalesData(DateTime(2024, 3, 2), 2300),
    SalesData(DateTime(2024, 3, 3), 1800),
    SalesData(DateTime(2024, 3, 4), 2600),
    SalesData(DateTime(2024, 3, 5), 2100),
    SalesData(DateTime(2024, 3, 6), 2800),
    SalesData(DateTime(2024, 3, 7), 200),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? 2
                      : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _buildStatCard(stat);
            },
          ),
          const SizedBox(height: 24),
          SalesChart(
            salesData: salesData,
            title: 'Weekly Sales Overview',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(StatItem stat) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: stat.backgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            width: double.infinity,
            child: Text(
              stat.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      stat.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Icon(
                    stat.icon,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SalesData {
  final DateTime date;
  final double sales;

  SalesData(this.date, this.sales);
}

class SalesChart extends StatelessWidget {
  final List<SalesData> salesData;
  final String title;

  const SalesChart({
    super.key,
    required this.salesData,
    this.title = 'Sales Chart',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4957),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('This Week'),
                      SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('dd MMM'),
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  interval: 350,
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey.shade200,
                    dashArray: const <double>[5, 5],
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x : \$point.y',
                  builder: (data, point, series, pointIndex, seriesIndex) {
                    final salesData = data as SalesData;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM yyyy').format(salesData.date),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sales: \$${salesData.sales.toInt()}',
                            style: const TextStyle(
                              color: Color(0xFF2C4957),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                series: <CartesianSeries>[
                  LineSeries<SalesData, DateTime>(
                    dataSource: salesData,
                    xValueMapper: (SalesData sales, _) => sales.date,
                    yValueMapper: (SalesData sales, _) => sales.sales,
                    color: const Color(0xFF2C4957),
                    width: 1.5,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 8,
                      width: 8,
                      borderWidth: 1.5,
                      borderColor: Color(0xFF2C4957),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
