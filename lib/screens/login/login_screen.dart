// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pos/screens/main_dashboard/main_dashboard_screen.dart';
import 'package:pos/utils/app_colors.dart';
import 'package:pos/utils/app_navigator.dart';
import 'package:pos/widgets/app_dropdown.dart';
import 'package:pos/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? selectedRole;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Add screen size detection
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/login_background.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Add scrolling support
            child: Card(
              // Update margin based on screen size
              margin: EdgeInsets.all(isTablet ? 32 : 16),
              color: Colors.white.withOpacity(0.5),
              child: Container(
                // Update constraints based on screen size
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : screenSize.width * 0.9,
                ),
                // Update padding based on screen size
                padding: EdgeInsets.all(isTablet ? 32 : 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Restaurant Name',
                      style: TextStyle(
                        fontSize: isTablet ? 30 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.restaurant,
                          size: 30, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 20),
                    AppDropdown(
                      value: selectedRole,
                      hintText: 'Select Role',
                      items: const [
                        'Manager',
                        'Staff',
                        'Chef',
                        'Waiter',
                        'Admin',
                        'Order Taker'
                      ],
                      onChanged: (newValue) {
                        setState(() {
                          selectedRole = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      hintText: 'Enter your password',
                      prefixIcon: Icons.password_outlined,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () {
                        _passwordFocusNode.unfocus();
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        AppNavigator.push(
                          context,
                          const MainDashboardScreen(),
                        );
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
