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
import 'package:pos/cubit/order/order_cubit.dart';
import 'package:pos/cubit/order/order_state.dart';
import 'package:pos/cubit/service_table/service_table_cubit.dart';
import 'package:pos/cubit/service_table/service_table_state.dart';
import 'package:pos/cubit/status/status_cubit.dart';
import 'package:pos/model/category/category_model.dart';
import 'package:pos/model/customer/customer_model.dart';
import 'package:pos/model/menu_item/menu_item_model.dart';
import 'package:pos/model/order/status_model.dart';
import 'package:pos/utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/widgets/card_item_widget.dart';
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

  final List<int> modifierQuantities = [];

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

  String? selectedPickupPointId;

  // Add a variable to hold the selected customer
  CustomerModel?
      selectedCustomer; // Assuming CustomerModel is the type of your customer
  bool isGuest = false; // Flag to indicate if the user is a guest

  // Add focus nodes
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _customerSearchFocusNode = FocusNode();

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
    context.read<ServiceTableCubit>().getServiceTables();
    context.read<ServiceTableCubit>().getPickup();

    // Add focus node listeners if needed
    _searchFocusNode.addListener(_onSearchFocusChange);
    _customerSearchFocusNode.addListener(_onCustomerSearchFocusChange);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _menuScrollController.dispose();
    super.dispose();
    kitchenNote.dispose();
    staffNote.dispose();
    paymentNote.dispose();
    customerSearch.dispose();

    // Dispose focus nodes
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _customerSearchFocusNode.removeListener(_onCustomerSearchFocusChange);
    _searchFocusNode.dispose();
    _customerSearchFocusNode.dispose();
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

  double calculateTotal() {
    return cartItems.fold(0, (total, item) {
      // Calculate the total for each item including modifiers
      double modifiersTotal = item.selectedModifiers
          .fold(0.0, (sum, modifier) => sum + modifier.price);
      return total + (item.menuItem.price * item.quantity) + modifiersTotal;
    });
  }

  // Focus change handlers
  void _onSearchFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      // Handle search focus lost
    }
  }

  void _onCustomerSearchFocusChange() {
    if (!_customerSearchFocusNode.hasFocus) {
      // Handle customer search focus lost
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure this is set to true
      backgroundColor: Colors.white,
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderSuccess) {
            // clear cart items
            setState(() {
              cartItems.clear();
            });

            kitchenNote.clear();
            staffNote.clear();
            paymentNote.clear();
            selectedCustomer = null;
            selectedPickupPointId = null;
            context.read<ServiceTableCubit>().selectedServiceTable = null;
          }
          if (state is OrderDeleteSuccess) {
            context.read<StatusCubit>().getOrderByStatus(status: "pending");
            context.read<StatusCubit>().getOrderByStatus(status: "preparing");
            context.read<StatusCubit>().getOrderByStatus(status: "ready");
            setState(() {
              cartItems.clear();
              context.read<OrderCubit>().ordersModel = null;
            });

            // Close dialogs
            Navigator.of(context).pop();

            // show snackbar
            final snackBar = SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

          if (state is OrdersItemDeleteSuccess) {
            // Refresh lists
            setState(() {
              context.read<OrderCubit>().ordersModel = null;
            });

            context.read<StatusCubit>().getOrderByStatus(status: "pending");
            context.read<StatusCubit>().getOrderByStatus(status: "preparing");
            context.read<StatusCubit>().getOrderByStatus(status: "ready");
            context.read<ServiceTableCubit>().getServiceTables();
            context.read<ServiceTableCubit>().getPickup();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item removed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is OrdersItemDeleteError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    // Clear All Button
                    TextButton.icon(
                      onPressed: context.read<OrderCubit>().ordersModel == null
                          ? () {
                              setState(() {
                                cartItems.clear();
                              });
                            }
                          : () {
                              // Show delete confirmation dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text('Delete Order'),
                                    content: const Text(
                                      'Are you sure you want to delete this order? This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Add your delete logic here
                                          await context
                                              .read<OrderCubit>()
                                              .deleteOrder(context
                                                  .read<OrderCubit>()
                                                  .ordersModel!
                                                  .id);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                      icon: context.read<OrderCubit>().ordersModel != null
                          ? const Icon(Icons.delete)
                          : const Icon(Icons.clear),
                      label: context.read<OrderCubit>().ordersModel != null
                          ? state is OrderDeleteLoading
                              ? const Text("Removing")
                              : const Text('Remove')
                          : const Text('Clear All'),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                        focusNode: _searchFocusNode,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: context.read<OrderCubit>().ordersModel == null
                          ? () async {
                              await context.read<OrderCubit>().submitOrder(
                                    instructions: {
                                      "kitchen": kitchenNote.text,
                                      "staff": staffNote.text,
                                      "payment": paymentNote.text
                                    },
                                    menuItems: cartItems
                                        .map((item) => {
                                              "menuItemId": item.menuItem.id,
                                              "quantity": item.quantity,
                                              if (item
                                                  .selectedModifiers.isNotEmpty)
                                                "modifiers": item
                                                    .selectedModifiers
                                                    .fold<Map<String, int>>({},
                                                        (map, modifier) {
                                                      map[modifier.id] =
                                                          (map[modifier.id] ??
                                                                  0) +
                                                              1;
                                                      return map;
                                                    })
                                                    .entries
                                                    .map((entry) => {
                                                          "modifierId":
                                                              entry.key,
                                                          "quantity":
                                                              entry.value
                                                        })
                                                    .toList()
                                            })
                                        .toList(),
                                    orderDetails: {
                                      "customerId":
                                          isGuest ? null : selectedCustomer?.id,
                                      "orderType": orderTypeValue.toLowerCase(),
                                      if (orderTypeValue == "Dining")
                                        "serviceTableId": context
                                            .read<ServiceTableCubit>()
                                            .selectedServiceTable
                                            ?.sId,
                                      if (orderTypeValue == "Takeaway")
                                        "pickupPointId": selectedPickupPointId,
                                    },
                                    orderType: orderTypeValue.toLowerCase(),
                                  );

                              context
                                  .read<StatusCubit>()
                                  .getOrderByStatus(status: "pending");
                              context
                                  .read<StatusCubit>()
                                  .getOrderByStatus(status: "preparing");
                              context
                                  .read<StatusCubit>()
                                  .getOrderByStatus(status: "ready");
                              context
                                  .read<ServiceTableCubit>()
                                  .getServiceTables();
                              context.read<ServiceTableCubit>().getPickup();
                            }
                          : () {},
                      icon: const Icon(Icons.check),
                      label: state is OrderLoading
                          ? const Text('Submitting...')
                          : context.read<OrderCubit>().ordersModel != null
                              ? const Text('Update')
                              : const Text('Submit'),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            context.read<OrderCubit>().ordersModel != null
                                ? const Color.fromARGB(255, 97, 110, 103)
                                : const Color.fromRGBO(0, 200, 83, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              // Categories
              Container(
                height: 100,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border:
                      Border(right: BorderSide(color: Colors.grey.shade200)),
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
                                child: SpinKitFadingCircle(
                                  color: Colors.white,
                                  size: 20.0,
                                )),
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
                    context.read<OrderCubit>().ordersModel != null
                        ? Expanded(
                            flex: 2,
                            child: state is OrderByIdLoading
                                ? const SpinKitFadingCircle(
                                    color: AppColors.primary,
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                          left: BorderSide(
                                              color: Colors.grey.shade200)),
                                    ),
                                    child: Column(
                                      children: [
                                        // cart id
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  print(
                                                      'Print: ${context.read<OrderCubit>().ordersModel!.tracking.toString()}');
                                                },
                                                child: Text(
                                                  'Print: ${context.read<OrderCubit>().ordersModel!.tracking.toString()}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              // cancel button
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      bool isAgreed = false;
                                                      final reasonController =
                                                          TextEditingController();

                                                      return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                          return Dialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(24),
                                                              width:
                                                                  500, // Set a fixed width for the dialog
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        const Text(
                                                                          'Cancelling Order',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                24,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        IconButton(
                                                                          icon:
                                                                              const Icon(Icons.close),
                                                                          onPressed: () =>
                                                                              Navigator.pop(context),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            16),
                                                                    const Text(
                                                                      'Make sure it will not be able to undone, What is the reason behind cancelling order?',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            24),
                                                                    TextField(
                                                                      controller:
                                                                          reasonController,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintText:
                                                                            'Enter cancellation reason',
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            Colors.grey[100],
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          borderSide:
                                                                              BorderSide.none,
                                                                        ),
                                                                      ),
                                                                      maxLines:
                                                                          3,
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            24),
                                                                    Row(
                                                                      children: [
                                                                        Checkbox(
                                                                          value:
                                                                              isAgreed,
                                                                          onChanged:
                                                                              (bool? value) {
                                                                            setState(() {
                                                                              isAgreed = value ?? false;
                                                                            });
                                                                          },
                                                                        ),
                                                                        const Text(
                                                                            'Agreed'),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            24),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        TextButton(
                                                                          onPressed: () =>
                                                                              Navigator.pop(context),
                                                                          child:
                                                                              const Text(
                                                                            'Close',
                                                                            style:
                                                                                TextStyle(color: Colors.black54),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                16),
                                                                        ElevatedButton(
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                const Color(0xFFFF4081),
                                                                            foregroundColor:
                                                                                Colors.white,
                                                                            padding:
                                                                                const EdgeInsets.symmetric(
                                                                              horizontal: 24,
                                                                              vertical: 12,
                                                                            ),
                                                                          ),
                                                                          onPressed: isAgreed
                                                                              ? () {
                                                                                  // Handle cancellation logic here
                                                                                  // You can use reasonController.text to get the reason
                                                                                  Navigator.pop(context);
                                                                                }
                                                                              : null,
                                                                          child:
                                                                              const Text('Confirm'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // cart headers
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // selected Customer
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.person),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      context
                                                          .read<OrderCubit>()
                                                          .ordersModel!
                                                          .customer
                                                          .name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.home),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      context
                                                          .read<OrderCubit>()
                                                          .ordersModel!
                                                          .customer
                                                          .address,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: true,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // cart items
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: context
                                                .read<OrderCubit>()
                                                .ordersModel!
                                                .orderDetails
                                                .items
                                                .length,
                                            itemBuilder: (context, index) {
                                              final orderStatus = context
                                                  .read<OrderCubit>()
                                                  .ordersModel!
                                                  .orderStatus;

                                              final item = context
                                                  .read<OrderCubit>()
                                                  .ordersModel!
                                                  .orderDetails
                                                  .items[index];

                                              return Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Add image container
                                                    Container(
                                                      width: 60,
                                                      height: 60,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            item.menuItem
                                                                    .image ??
                                                                "",
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    // Existing content
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  item.menuItem
                                                                      .name,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'AED ${(item.menuItem.price * item.quantity).toStringAsFixed(2)}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  'Quantity: ${item.quantity}'),
                                                              Text(
                                                                  'AED ${item.menuItem.price.toStringAsFixed(2)} each'),
                                                            ],
                                                          ),
                                                          // Show modifiers if any
                                                          if (item.modifiers
                                                              .isNotEmpty) ...[
                                                            const SizedBox(
                                                                height: 8),
                                                            const Text(
                                                              'Modifiers:',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            ...item.modifiers
                                                                .map(
                                                              (modifier) =>
                                                                  Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 4),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        '+ ${modifier.name}'),
                                                                    Text(
                                                                        'AED ${(modifier.price * modifier.quantity).toStringAsFixed(2)}'),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          const SizedBox(
                                                              height: 10),
                                                          // show status
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: orderStatus ==
                                                                      'pending'
                                                                  ? Colors
                                                                      .orange
                                                                  : orderStatus ==
                                                                          'ready'
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Text(
                                                              "Order Status: $orderStatus",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          // three buttons in a row, modifiers, status , remove
                                                          Visibility(
                                                            visible: context
                                                                        .read<
                                                                            OrderCubit>()
                                                                        .ordersModel!
                                                                        .orderStatus ==
                                                                    'pending' ||
                                                                context
                                                                        .read<
                                                                            OrderCubit>()
                                                                        .ordersModel!
                                                                        .orderStatus ==
                                                                    'preparing',
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {},
                                                                  child:
                                                                      const Text(
                                                                    "Modifiers",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                GestureDetector(
                                                                  onTap: () {},
                                                                  child:
                                                                      const Text(
                                                                    "Status",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    context
                                                                        .read<
                                                                            OrderCubit>()
                                                                        .deleteOrderItemById(
                                                                          context
                                                                              .read<OrderCubit>()
                                                                              .ordersModel!
                                                                              .id, // Order ID
                                                                          item.id, // Order Item ID
                                                                        );
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Remove",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // Cart total
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                                top: BorderSide(
                                                    color:
                                                        Colors.grey.shade200)),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.tertiary,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Total:',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  '\$${context.read<OrderCubit>().ordersModel!.orderDetails.items.map((item) => item.menuItem.price * item.quantity).reduce((a, b) => a + b).toStringAsFixed(2)}',
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
                          )
                        : Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                    left: BorderSide(
                                        color: Colors.grey.shade200)),
                              ),
                              child: Column(
                                children: [
                                  // Cart header
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              showCustomerSelectionBottomSheet(
                                                  false),
                                          child: Text(
                                            selectedCustomer != null || isGuest
                                                ? 'Customer is:\n${selectedCustomer?.name ?? 'Guest'}'
                                                : 'Select Customer',
                                            style: TextStyle(
                                              color: selectedCustomer != null ||
                                                      isGuest
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        BlocConsumer<ServiceTableCubit,
                                            ServiceTableState>(
                                          listener: (context, state) {
                                            print(state);
                                            if (state is ServiceTableSuccess) {
                                              setState(() {
                                                context
                                                        .read<ServiceTableCubit>()
                                                        .serviceTables =
                                                    state.response;
                                              });
                                            }
                                            if (state is ServiceTableError) {
                                              context
                                                  .read<ServiceTableCubit>()
                                                  .pickupPoints = [];
                                            }
                                            if (state is PickupSuccess) {
                                              context
                                                      .read<ServiceTableCubit>()
                                                      .pickupPoints =
                                                  state.response;
                                            }
                                            if (state is PickupError) {
                                              context
                                                  .read<ServiceTableCubit>()
                                                  .pickupPoints = [];
                                            }
                                          },
                                          builder: (context, state) {
                                            return GestureDetector(
                                              onTap: () {
                                                // Call the showSelectTableDialog method directly without using its return value
                                                if (orderTypeValue ==
                                                    "Dining") {
                                                  showSelectTableDialog();
                                                } else if (orderTypeValue ==
                                                    "Takeaway") {
                                                  showSelectPickupDialog();
                                                } else {
                                                  showCustomerSelectionBottomSheet(
                                                      orderTypeValue ==
                                                              "Delivery"
                                                          ? true
                                                          : false);
                                                }
                                              },
                                              child: state
                                                      is ServiceTableLoading
                                                  ? const Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        color:
                                                            AppColors.primary,
                                                        size: 15,
                                                      ),
                                                    )
                                                  : orderTypeValue == "Dining"
                                                      ? context
                                                                  .read<
                                                                      ServiceTableCubit>()
                                                                  .selectedServiceTable ==
                                                              null
                                                          ? const Text(
                                                              'Select Table')
                                                          : Text(
                                                              context
                                                                      .read<
                                                                          ServiceTableCubit>()
                                                                      .selectedServiceTable!
                                                                      .tableName ??
                                                                  "",
                                                              style: TextStyle(
                                                                color: context
                                                                            .read<
                                                                                ServiceTableCubit>()
                                                                            .selectedServiceTable!
                                                                            .status ==
                                                                        'available'
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .grey,
                                                              ),
                                                            )
                                                      : orderTypeValue ==
                                                              "Takeaway"
                                                          ? const Text(
                                                              "Select Pickup")
                                                          : const Text(
                                                              "Select Shipping (Opt)"),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Cart items
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: cartItems.length,
                                        itemBuilder: (context, index) {
                                          final item = cartItems[index];
                                          return CartItemWidget(
                                            item: item,
                                            onQuantityChanged: (newQuantity) {
                                              setState(() {
                                                if (newQuantity > 0) {
                                                  cartItems[index].quantity =
                                                      newQuantity;
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
                                          top: BorderSide(
                                              color: Colors.grey.shade200)),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.tertiary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
          );
        },
      ),
    );
  }

  void _showOrdersInProcess() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Orders in Process',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // TabBar
                  TabBar(
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(
                        icon:
                            const Icon(Icons.access_time, color: Colors.orange),
                        text:
                            'Pending (${context.read<StatusCubit>().pendingStatusList.length})',
                      ),
                      Tab(
                        icon: Icon(Icons.kitchen, color: Colors.pink[200]),
                        text:
                            'Preparing (${context.read<StatusCubit>().preparingStatusList.length})',
                      ),
                      Tab(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.green),
                        text:
                            'Ready (${context.read<StatusCubit>().readyStatusList.length})',
                      ),
                    ],
                  ),
                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOrderList(
                            context.read<StatusCubit>().pendingStatusList),
                        _buildOrderList(
                            context.read<StatusCubit>().preparingStatusList),
                        _buildOrderList(
                            context.read<StatusCubit>().readyStatusList),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildOrderList(List<StatusModel> orders) {
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
            onTap: () {
              context.read<OrderCubit>().getOrdersById(order.id);
              // Refresh all necessary data
              context.read<StatusCubit>().getOrderByStatus(status: "pending");
              context.read<StatusCubit>().getOrderByStatus(status: "preparing");
              context.read<StatusCubit>().getOrderByStatus(status: "ready");
              context.read<ServiceTableCubit>().getServiceTables();
              context.read<ServiceTableCubit>().getPickup();

              setState(() {});

              Navigator.pop(context);
            },
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

  void showSelectPickupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Select Pickup Point',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Grid of pickup points
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Number of columns
                      childAspectRatio: 2.5, // Adjust aspect ratio as needed
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount:
                        context.read<ServiceTableCubit>().pickupPoints.length,
                    itemBuilder: (context, index) {
                      final pickupPoint =
                          context.read<ServiceTableCubit>().pickupPoints[index];
                      return _buildPickupPointCard(
                        id: pickupPoint.sId ?? "",
                        title: pickupPoint.placeTitle ?? "",
                        contactName: pickupPoint.personName ?? "",
                        phone: pickupPoint.phone ?? "",
                        address: pickupPoint.address ?? "",
                        isSelected: selectedPickupPointId == pickupPoint.sId,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickupPointCard({
    required String id,
    required String title,
    required String contactName,
    required String phone,
    required String address,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPickupPointId = id;
        });
        Navigator.of(context).pop();
      },
      child: Card(
        shadowColor: isSelected ? Colors.amber : Colors.transparent,
        color: isSelected ? Colors.blue[100] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: isSelected ? Colors.blue : Colors.grey.shade300),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.center,
          leading: Radio<String>(
            value: id,
            groupValue: selectedPickupPointId,
            onChanged: (String? value) {
              setState(() {
                selectedPickupPointId = value;
              });
              Navigator.of(context).pop();
            },
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Contact: $contactName'),
              Text('Phone: $phone'),
              Text('Address: $address'),
            ],
          ),
        ),
      ),
    );
  }

  void showSelectTableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Table',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Table cards
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount:
                        context.read<ServiceTableCubit>().serviceTables.length,
                    itemBuilder: (context, index) {
                      final table = context
                          .read<ServiceTableCubit>()
                          .serviceTables[index];
                      return GestureDetector(
                        onTap: () {
                          if (table.status == 'available') {
                            context
                                .read<ServiceTableCubit>()
                                .selectedServiceTable = table;
                            setState(() {});
                            Navigator.pop(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => const AlertDialog(
                                title: Text(
                                  'Table is already occupied\n Please select another table',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: table.status == 'available'
                              ? Colors.green[100]
                              : Colors.red[100],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    table.tableName ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Capacity: ${table.capacity}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  table.status == 'available'
                                      ? 'Available'
                                      : 'Occupied',
                                  style: TextStyle(
                                    color: table.status == 'available'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
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

  void showCustomerSelectionBottomSheet(bool isDelivery) {
    CustomerCubit.get(context).customerList = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24),
            child: BlocConsumer<CustomerCubit, CustomerState>(
              listener: (context, state) {
                if (state is CustomerSuccess) {
                  setState(() {
                    CustomerCubit.get(context).customerList = state.response;
                  });
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select Customer',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Display selected customer information or "Guest"
                      if (!(isGuest || selectedCustomer == null))
                        Container(
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (selectedCustomer != null) ...[
                                Text('Name: ${selectedCustomer!.name}'),
                                Text('Phone: ${selectedCustomer!.phone}'),
                                Text('Email: ${selectedCustomer!.email}'),
                                Text('Address: ${selectedCustomer!.address}'),
                              ] else ...[
                                if (isGuest)
                                  const Text('You are continuing as a guest.'),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Search TextField
                      TextField(
                        focusNode: _customerSearchFocusNode,
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
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (state is CustomerError)
                                const Text(
                                  'No customers found. Try a different search or add a new customer.',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                )
                              else if (CustomerCubit.get(context)
                                  .customerList
                                  .isEmpty)
                                const Text(
                                  'Search for existing customer or add a new one',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                )
                              else
                                ...CustomerCubit.get(context)
                                    .customerList
                                    .map((customer) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedCustomer = customer;
                                                isGuest = false;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.person,
                                                      size: 40),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(customer.name,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        18)),
                                                        Text(customer.phone,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                        Text(customer.email,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                        Text(customer.address,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          if (!isDelivery)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedCustomer = null;
                                    isGuest = true;
                                  });
                                  Navigator.pop(context);
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
                );
              },
            ),
          ),
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
            modifierQuantities,
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

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
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
          ),
        );
      },
    );
  }

  void _showModifiersBottomSheet(
      List<ModifierModel> modifiers, CartItem cartItem) {
    // Create a list to keep track of selected modifiers and their quantities
    List<bool> selectedModifiers = List.generate(modifiers.length, (index) {
      return cartItem.selectedModifiers.contains(modifiers[index]);
    });

    List<int> modifierQuantities = List.generate(modifiers.length, (index) {
      if (cartItem.selectedModifiers.contains(modifiers[index])) {
        return cartItem.selectedModifiers
            .where((modifier) => modifier == modifiers[index])
            .length;
      }
      return 0;
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
                        return Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(modifiers[index].name),
                                subtitle: Text('AED ${modifiers[index].price}'),
                                value: selectedModifiers[index],
                                activeColor: AppColors.primary,
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedModifiers[index] = value ?? false;
                                    // Reset quantity to 1 when selected, 0 when unselected
                                    modifierQuantities[index] =
                                        value ?? false ? 1 : 0;
                                  });
                                },
                              ),
                            ),
                            if (selectedModifiers[index]) ...[
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: modifierQuantities[index] > 1
                                    ? () {
                                        setState(() {
                                          modifierQuantities[index]--;
                                        });
                                      }
                                    : null,
                              ),
                              Text(
                                modifierQuantities[index].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    modifierQuantities[index]++;
                                  });
                                },
                              ),
                            ],
                          ],
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
                          // Collect selected modifiers with their quantities
                          List<ModifierModel> selected = [];
                          for (int i = 0; i < modifiers.length; i++) {
                            if (selectedModifiers[i]) {
                              // Add the modifier multiple times based on quantity
                              for (int j = 0; j < modifierQuantities[i]; j++) {
                                selected.add(modifiers[i]);
                              }
                            }
                          }

                          // Update the cart item with selected modifiers
                          setState(() {
                            cartItem.selectedModifiers.clear();
                            cartItem.selectedModifiers.addAll(selected);
                          });

                          Navigator.pop(context);
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
  final List<int> modifierQuantities;
  final List<ModifierModel> modifiers; // All modifiers
  List<ModifierModel> selectedModifiers; // Change to mutable list

  CartItem(
    this.menuItem,
    this.modifierQuantities, {
    required this.quantity,
    required this.modifiers,
    List<ModifierModel>? selectedModifiers, // Accept as a parameter
  }) : selectedModifiers =
            selectedModifiers ?? []; // Initialize as an empty list

  // New constructor to create CartItem from MenuItemModel
  CartItem.fromMenuItem(this.menuItem, this.modifierQuantities)
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
