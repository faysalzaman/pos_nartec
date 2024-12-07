// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pos/cubit/category/category_cubit.dart';
import 'package:pos/cubit/category/category_state.dart';
import 'package:pos/cubit/customer/customer_cubit.dart';
import 'package:pos/cubit/customer/customer_state.dart';
import 'package:pos/cubit/menu_item/menu_item_cubit.dart';
import 'package:pos/cubit/menu_item/menu_item_state.dart';
import 'package:pos/cubit/status/status_cubit.dart';
import 'package:pos/model/category/category_model.dart';
import 'package:pos/model/customer/customer_model.dart';
import 'package:pos/model/menu_item/menu_item_model.dart';
import 'package:pos/utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/widgets/card_item_widget.dart';
import 'package:pos/widgets/orders_in_process_bottom_sheet.dart';
import 'package:pos/widgets/placeholders/category_placeholder.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  String orderTypeValue = 'Dining';
  final List<String> orderTypeList = ['Dining', 'Takeaway', 'Delivery'];

  List<CartItem> cartItems = [];
  String? selectedCategory;

  // cubit
  final MenuItemCubit menuCubit = MenuItemCubit();

  final List<MenuItemModel> menuItems = [];
  final List<String> modifiersList = [];

  // Notes
  TextEditingController kitchenNote = TextEditingController();
  TextEditingController staffNote = TextEditingController();
  TextEditingController paymentNote = TextEditingController();
  TextEditingController customerSearch = TextEditingController();

  List<Category> categories = [];

  int currentPage = 1;
  final int limit = 10;

  int menuItemPage = 1;
  final int menuItemLimit = 10;

  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _menuScrollController = ScrollController();
  bool isLoadingMoreMenuItems = false;

  // Add a variable to hold the selected customer
  CustomerModel?
      selectedCustomer; // Assuming CustomerModel is the type of your customer
  bool isGuest = false; // Flag to indicate if the user is a guest

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _scrollController.addListener(_onScroll);
    _menuScrollController.addListener(_onMenuScroll);
    menuCubit.getMenuItems(
      page: menuItemPage,
      limit: menuItemLimit,
      category: "",
    );
    context.read<StatusCubit>().getOrderByStatus(status: "pending");
    context.read<StatusCubit>().getOrderByStatus(status: "preparing");
    context.read<StatusCubit>().getOrderByStatus(status: "ready");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _menuScrollController.dispose();
    super.dispose();
    kitchenNote.dispose();
    staffNote.dispose();
    paymentNote.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreCategories();
    }
  }

  void _onMenuScroll() {
    if (_menuScrollController.position.pixels ==
        _menuScrollController.position.maxScrollExtent) {
      _loadMoreMenuItems();
    }
  }

  void _fetchCategories() {
    context.read<CategoryCubit>().getCategories(
          page: currentPage,
          limit: limit,
        );
  }

  void _loadMoreCategories() {
    if (!isLoadingMore) {
      isLoadingMore = true; // Update the flag without rebuilding
      _fetchCategories();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isLoadingMore = false;
          currentPage++;
        });
      });
    }
  }

  void _loadMoreMenuItems() {
    if (!isLoadingMoreMenuItems) {
      setState(() {
        isLoadingMoreMenuItems = true;
        menuItemPage++;
      });
      menuCubit.getMenuItems(
        page: menuItemPage,
        limit: menuItemLimit,
        category: selectedCategory ?? "",
      );
    }
  }

  List<ModifierModel> selectedModifiers = [];

  // Method to update the cart item when modifiers are selected
  void updateCartItem(CartItem updatedItem) {
    setState(() {
      // Find the index of the item in the cart and update it
      int index = cartItems.indexOf(updatedItem);
      if (index != -1) {
        cartItems[index] = updatedItem;
      }
    });
  }

  void _showOrdersInProcess() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return OrdersInProcessBottomSheet(
          pendingList: context.read<StatusCubit>().pendingStatusList,
          preparingList: context.read<StatusCubit>().preparingStatusList,
          readyList: context.read<StatusCubit>().readyStatusList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure this is set to true
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Clear All Button
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      cartItems.clear();
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                // All Orders Button
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.list),
                  label: const Text('All orders'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2C4957),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(width: 16),
                // Order Type Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text(
                        'Select order type',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      value: orderTypeValue,
                      items: orderTypeList.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          orderTypeValue = value!;
                        });
                      },
                      dropdownColor: Colors.white,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Search TextField
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search product by names',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Action Buttons
                TextButton.icon(
                  onPressed: _showNotesDialog,
                  icon: const Icon(Icons.note),
                  label: const Text('Notes'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _showOrdersInProcess,
                  icon: const Icon(Icons.pending),
                  label: const Text('In Process'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          // Categories
          Container(
            height: 100,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: BlocConsumer<CategoryCubit, CategoryState>(
              listener: (context, state) {
                if (state is CategorySuccess) {
                  // menuCubit.getMenuItems(
                  //   page: menuItemPage,
                  //   limit: menuItemLimit,
                  //   search: "",
                  //   category: categories.first.id,
                  // );
                  setState(() {
                    if (currentPage == 1) {
                      categories = state.response.categories;
                    } else {
                      categories.addAll(state.response.categories);
                    }
                    isLoadingMore = false;
                  });
                }
              },
              builder: (context, state) {
                if (state is CategoryLoading && categories.isEmpty) {
                  return const CategoryPlaceholderWidget();
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...categories.map((category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryItem(
                              category,
                              selectedCategory == category.id,
                            ),
                          )),
                      if (isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Main content area
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          right: BorderSide(color: Colors.grey.shade200)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocConsumer<MenuItemCubit, MenuItemState>(
                      bloc: menuCubit,
                      listener: (context, state) {
                        if (state is MenuItemSuccess) {
                          setState(() {
                            if (menuItemPage == 1) {
                              menuItems.clear();
                            }
                            menuItems.addAll(state.response.menuItems);
                            isLoadingMoreMenuItems = false;
                          });
                        } else if (state is MenuItemError) {
                          setState(() {
                            isLoadingMoreMenuItems = false;
                          });
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Error!',
                              message: state.message,
                              contentType: ContentType.failure,
                            ),
                          );
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(snackBar);
                        }
                      },
                      builder: (context, state) {
                        if (state is MenuItemLoading && menuItems.isEmpty) {
                          return const Center(
                            child: SpinKitFadingCircle(
                              color: AppColors.primary,
                            ),
                          );
                        } else if (menuItems.isEmpty) {
                          return Center(
                            child: Text(
                              'Select a category to view items  ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        }
                        return GridView.builder(
                          controller: _menuScrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: menuItems.length +
                              (isLoadingMoreMenuItems ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == menuItems.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: SpinKitFadingCircle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            return _buildProductCard(
                              menuItems[index].modifiers,
                              menuItems[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Right sidebar - Cart
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(left: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      children: [
                        // Cart header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _showCustomerSelectionBottomSheet,
                                child: Text(
                                  selectedCustomer != null || isGuest
                                      ? 'Customer is:\n${selectedCustomer?.name ?? 'Guest'}'
                                      : 'Select Customer',
                                  style: TextStyle(
                                    color: selectedCustomer != null || isGuest
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (orderTypeValue == "Dining") {
                                  } else if (orderTypeValue == "Takeaway") {
                                  } else {}
                                },
                                child: orderTypeValue == "Dining"
                                    ? const Text('Select Table')
                                    : orderTypeValue == "Takeaway"
                                        ? const Text("Select Pickup")
                                        : const Text("Select Shipping (Opt)"),
                              ),
                            ],
                          ),
                        ),
                        // Cart items
                        Expanded(
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return CartItemWidget(
                                  item: item,
                                  onQuantityChanged: (newQuantity) {
                                    setState(() {
                                      if (newQuantity > 0) {
                                        cartItems[index].quantity = newQuantity;
                                      } else {
                                        cartItems.removeAt(index);
                                      }
                                    });
                                  },
                                  onModifier: () {
                                    _showModifiersBottomSheet(
                                        item.modifiers, item);
                                  },
                                  onRemove: () {
                                    setState(() {
                                      cartItems.removeAt(index);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        // Cart total
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '\$${calculateTotal().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerSelectionBottomSheet() {
    CustomerCubit.get(context).customerList = [];
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BlocConsumer<CustomerCubit, CustomerState>(
          listener: (context, state) {
            if (state is CustomerSuccess) {
              setState(() {
                CustomerCubit.get(context).customerList = state.response;
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Customer',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Display selected customer information or "Guest"
                    isGuest || selectedCustomer == null
                        ? const SizedBox()
                        : Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCustomer != null
                                      ? 'Selected Customer:'
                                      : isGuest
                                          ? 'You are continuing as a guest.'
                                          : '',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                if (selectedCustomer != null) ...[
                                  Text('Name: ${selectedCustomer!.name}'),
                                  Text('Phone: ${selectedCustomer!.phone}'),
                                  Text('Email: ${selectedCustomer!.email}'),
                                  Text('Address: ${selectedCustomer!.address}'),
                                ] else ...[
                                  isGuest
                                      ? const Text(
                                          'You are continuing as a guest.')
                                      : const SizedBox(),
                                ],
                              ],
                            ),
                          ),
                    const SizedBox(height: 16),
                    // Search TextField
                    TextField(
                      controller: customerSearch,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          if (customerSearch.text.isNotEmpty) {
                            CustomerCubit.get(context).customerList = [];
                          }
                        } else {
                          CustomerCubit.get(context).searchCustomer(value);
                        }
                      },
                      onEditingComplete: () {
                        if (customerSearch.text.isEmpty) {
                          CustomerCubit.get(context).customerList = [];
                        } else {
                          CustomerCubit.get(context)
                              .searchCustomer(customerSearch.text);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search for existing customer',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Customer list
                    if (state is CustomerError)
                      const Text(
                        'No customers found. Try a different search or add a new customer.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      )
                    else if (CustomerCubit.get(context).customerList.isEmpty)
                      const Text(
                        'Search for existing customer or add a new one',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            CustomerCubit.get(context).customerList.length,
                        itemBuilder: (context, index) {
                          final customer =
                              CustomerCubit.get(context).customerList[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCustomer =
                                    customer; // Save the selected customer
                                isGuest =
                                    false; // Set isGuest to false when a customer is selected
                              });
                              Navigator.pop(context); // Close the bottom sheet
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 40),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(customer.name,
                                            style:
                                                const TextStyle(fontSize: 18)),
                                        Text(customer.phone,
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        Text(customer.email,
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        Text(customer.address,
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    // Continue as Guest Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // add new customer
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              _showAddCustomerDialog();
                            },
                            child: const Text(
                              'Add New Customer',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                        // Continue as Guest Button
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                selectedCustomer =
                                    null; // Set selectedCustomer to null
                                isGuest =
                                    true; // Set isGuest to true when continuing as guest
                              });
                              Navigator.pop(context); // Close the bottom sheet
                            },
                            child: const Text(
                              'Continue as Guest',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.pink)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryItem(Category category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category.id;
          menuItemPage = 1;
          menuItems.clear();
        });
        menuCubit.getMenuItems(
          page: menuItemPage,
          limit: menuItemLimit,
          category: selectedCategory ?? "",
        );
      },
      child: Container(
        decoration: !isSelected
            ? null
            : BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                category.image,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.category,
                    size: 40,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    List<ModifierModel> modifiers,
    MenuItemModel menuItem,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          cartItems.add(CartItem(
            menuItem,
            quantity: 1,
            modifiers: modifiers,
          ));
        });
      },
      child: Card(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                  image: DecorationImage(
                    image: NetworkImage(menuItem.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${menuItem.price.toString().replaceAll('\$', '')}',
                    style: const TextStyle(
                      color: Colors.pink,
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

  double calculateTotal() {
    return cartItems.fold(0, (total, item) {
      // Calculate the total for each item including modifiers
      double modifiersTotal = item.selectedModifiers
          .fold(0.0, (sum, modifier) => sum + modifier.price);
      return total +
          (item.menuItem.price * item.quantity) +
          (modifiersTotal * item.quantity);
    });
  }

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Notes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kitchen Note
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kitchen note',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: kitchenNote,
                            decoration: const InputDecoration(
                              hintText:
                                  'Instructions to chef will be displayed in kitchen along order details',
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Staff Note
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Staff note',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: staffNote,
                            decoration: const InputDecoration(
                              hintText: 'Staff note for internal use',
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Payment Note
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment note',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: paymentNote,
                            decoration: const InputDecoration(
                              hintText: 'Payment note for internal use',
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Save notes logic here
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C4957),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Save Notes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showModifiersBottomSheet(
      List<ModifierModel> modifiers, CartItem cartItem) {
    // Create a list to keep track of selected modifiers
    List<bool> selectedModifiers = List.generate(modifiers.length, (index) {
      // Check if the modifier is already selected
      return cartItem.selectedModifiers.contains(modifiers[index]);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (modifiers.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Update food modifiers',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: List.generate(modifiers.length, (index) {
                        return CheckboxListTile(
                          title: Text(modifiers[index].name),
                          subtitle: Text('AED ${modifiers[index].price}'),
                          value: selectedModifiers[index],
                          activeColor:
                              AppColors.primary, // Set the checked color
                          onChanged: (bool? value) {
                            setState(() {
                              selectedModifiers[index] = value ?? false;
                            });
                          },
                        );
                      }),
                    ),
                  ] else ...[
                    const Text('No modifiers available.',
                        style: TextStyle(fontSize: 18)),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.pink)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Collect selected modifiers
                          List<ModifierModel> selected = [];
                          for (int i = 0; i < modifiers.length; i++) {
                            if (selectedModifiers[i]) {
                              selected.add(modifiers[i]);
                            }
                          }

                          // Update the cart item with selected modifiers
                          setState(() {
                            cartItem.selectedModifiers.clear();
                            cartItem.selectedModifiers.addAll(selected);
                          });

                          // Notify the parent widget to rebuild
                          Navigator.pop(context);
                          // Trigger a rebuild of the CartItemWidget
                          updateCartItem(cartItem);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C4957),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCustomerDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Add New Customer',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400, // Set a fixed width for the dialog
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter customer name',
                      labelText: 'Name',
                    ),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      hintText: 'Enter customer phone',
                      labelText: 'Phone',
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter customer email',
                      labelText: 'Email',
                    ),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: 'Enter customer address',
                      labelText: 'Address',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                await context.read<CustomerCubit>().addCustomer(
                      name: nameController.text,
                      phone: phoneController.text,
                      email: emailController.text,
                      address: addressController.text,
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Add Customer'),
            ),
          ],
        );
      },
    );
  }
}

class CartItem {
  final MenuItemModel menuItem;
  int quantity;
  final List<ModifierModel> modifiers; // All modifiers
  List<ModifierModel> selectedModifiers; // Change to mutable list

  CartItem(
    this.menuItem, {
    required this.quantity,
    required this.modifiers,
    List<ModifierModel>? selectedModifiers, // Accept as a parameter
  }) : selectedModifiers =
            selectedModifiers ?? []; // Initialize as an empty list if null

  // New constructor to create CartItem from MenuItemModel
  CartItem.fromMenuItem(this.menuItem)
      : modifiers = menuItem.modifiers,
        quantity = 1, // Default quantity to 1
        selectedModifiers = []; // Initialize as an empty list

  // Method to get selected modifiers from the instance variable
  List<ModifierModel>? getSelectedModifiers() {
    return selectedModifiers.isNotEmpty
        ? selectedModifiers
        : null; // Return null if no modifiers are selected
  }
}
