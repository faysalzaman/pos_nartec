// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:pos/screens/main_dashboard/dashboard/dashboard_screen.dart';
import 'package:pos/screens/main_dashboard/expenses/expense_type/expense_type_screen.dart';
import 'package:pos/screens/main_dashboard/expenses/expenses/expenses_screen.dart';
import 'package:pos/screens/main_dashboard/foods/categories/categories_screen.dart';
import 'package:pos/screens/main_dashboard/foods/menu_items/menu_items_screen.dart';
import 'package:pos/screens/main_dashboard/foods/modifiers/modifiers_screen.dart';
import 'package:pos/screens/main_dashboard/kitchen/kitchen_screen.dart';
import 'package:pos/screens/main_dashboard/pos/pos_screen.dart';
import 'package:pos/screens/main_dashboard/sales/sales_screen.dart';
import 'package:pos/utils/app_colors.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  Widget _currentScreen = const DashboardScreen();
  String _currentTitle = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          final isMediumTablet = MediaQuery.of(context).size.width >= 800;
          final iconSize = isMediumTablet ? 24.0 : 20.0;
          final fontSize = isMediumTablet ? 16.0 : 14.0;
          final paddingSize = isMediumTablet ? 24.0 : 16.0;

          return Drawer(
            backgroundColor: AppColors.primary,
            child: ListView(
              children: [
                // Logo and title
                Padding(
                  padding: EdgeInsets.all(paddingSize),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: iconSize,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.restaurant_menu,
                          color: const Color(0xFF004D40),
                          size: iconSize,
                        ),
                      ),
                      SizedBox(width: paddingSize / 2),
                      if (isMediumTablet)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Restaurant POS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Serving since 2023',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: fontSize * 0.75,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Existing menu items
                _buildMenuItem(Icons.dashboard, 'Dashboard',
                    _currentTitle == 'Dashboard', fontSize),
                _buildMenuItem(Icons.analytics, 'Sales',
                    _currentTitle == 'Sales', fontSize),
                // Sales & POS Section
                _buildSectionHeader('Sales & POS', fontSize),
                _buildMenuItem(Icons.point_of_sale, 'POS',
                    _currentTitle == 'POS', fontSize),
                _buildMenuItem(Icons.kitchen, 'Kitchen',
                    _currentTitle == 'Kitchen', fontSize),
                // Food Management Section
                _buildSectionHeader('Food Management', fontSize),
                _buildMenuItem(Icons.category, 'Categories',
                    _currentTitle == 'Categories', fontSize),
                _buildMenuItem(Icons.restaurant_menu, 'Menu Items',
                    _currentTitle == 'Menu Items', fontSize),
                _buildMenuItem(Icons.edit_note, 'Modifiers',
                    _currentTitle == 'Modifiers', fontSize),
                // Expense Management Section
                _buildSectionHeader('Expense Management', fontSize),
                _buildMenuItem(Icons.account_balance_wallet, 'Expense Type',
                    _currentTitle == 'Expense Type', fontSize),
                _buildMenuItem(Icons.money_off, 'Expenses',
                    _currentTitle == 'Expenses', fontSize),
              ],
            ),
          );
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMediumTablet = constraints.maxWidth >= 800;
          final iconSize = isMediumTablet ? 24.0 : 20.0;
          final headerFontSize = isMediumTablet ? 24.0 : 20.0;
          final paddingSize = isMediumTablet ? 24.0 : 16.0;

          return Container(
            color: const Color(0xFFF5F6FA),
            child: Padding(
              padding: EdgeInsets.all(paddingSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                            Text(
                              _currentTitle,
                              style: TextStyle(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Sunday, November 3, 2024',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '08:36:10 PM',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: paddingSize),
                  Expanded(child: _currentScreen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, double fontSize) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.orange,
          fontSize: fontSize * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, bool isSelected, double fontSize) {
    return Container(
      color:
          isSelected ? Colors.deepOrange.withOpacity(0.7) : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white,
            fontSize: fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          setState(() {
            _currentTitle = title;
            switch (title) {
              case 'Dashboard':
                _currentScreen = const DashboardScreen();
                break;
              case 'Sales':
                _currentScreen = SalesOrdersScreen();
                break;
              case 'POS':
                _currentScreen = POSScreen();
                break;
              case 'Kitchen':
                _currentScreen = const KitchenScreen();
                break;
              case 'Expense Type':
                _currentScreen = const ExpenseTypeScreen();
                break;
              case 'Expenses':
                _currentScreen = const ExpensesScreen();
                break;
              case 'Categories':
                _currentScreen = const CategoriesScreen();
                break;
              case 'Menu Items':
                _currentScreen = const MenuItemsScreen();
                break;
              case 'Modifiers':
                _currentScreen = const ModifiersScreen();
                break;
              default:
                _currentScreen = const DashboardScreen();
                break;
            }
          });
        },
      ),
    );
  }
}
