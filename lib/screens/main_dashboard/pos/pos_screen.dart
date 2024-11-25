import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pos/cubit/category/category_cubit.dart';
import 'package:pos/cubit/category/category_state.dart';
import 'package:pos/cubit/menu_item/menu_item_cubit.dart';
import 'package:pos/cubit/menu_item/menu_item_state.dart';
import 'package:pos/model/category/category_model.dart';
import 'package:pos/model/menu_item/menu_item_model.dart';
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
  String? orderTypeValue;
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

  List<Category> categories = [];

  int currentPage = 1;
  final int limit = 10;

  int menuItemPage = 1;
  final int menuItemLimit = 10;

  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _menuScrollController = ScrollController();
  bool isLoadingMoreMenuItems = false;

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
      setState(() {
        isLoadingMore = true;
        currentPage++;
      });
      _fetchCategories();
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

  @override
  Widget build(BuildContext context) {
    return Column(
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
                        orderTypeValue = value;
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
                onPressed: _showInProcessDialog,
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
                    border:
                        Border(right: BorderSide(color: Colors.grey.shade200)),
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
                        itemCount:
                            menuItems.length + (isLoadingMoreMenuItems ? 1 : 0),
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
                              bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Select Customer'),
                            Text('Select Table'),
                          ],
                        ),
                      ),
                      // Cart items
                      Expanded(
                        child: ListView.builder(
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
                                _showModifiersBottomSheet(item.modifiers, item);
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${menuItem.price.toString().replaceAll('\$', '')}',
                    style: TextStyle(color: Colors.grey.shade600),
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
    return cartItems.fold(
        0, (total, item) => total + (item.menuItem.price * item.quantity));
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

  void _showInProcessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Orders in process',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Tab buttons
                Row(
                  children: [
                    _buildTabButton(
                      icon: Icons.pending,
                      label: 'Pending',
                      count: '0',
                      color: Colors.orange,
                      onPressed: () {
                        setState(() {
                          print('Pending');
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildTabButton(
                      icon: Icons.restaurant,
                      label: 'Preparing',
                      count: '0',
                      color: Colors.blue[900]!,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    _buildTabButton(
                      icon: Icons.check_circle,
                      label: 'Ready',
                      count: '32',
                      color: Colors.green,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Orders list
                Expanded(
                  child: ListView.builder(
                    itemCount: 5, // Replace with actual orders count
                    itemBuilder: (context, index) => _buildOrderItem(),
                  ),
                ),
                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #241107265904',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Progress: 100%'),
            ],
          ),
          SizedBox(height: 8),
          Text('Type: takeaway (Est incididunt dolo)'),
          Text('Customer: Guest'),
          Text('Created at: 11/7/2024, 11:12:12 AM'),
          Text('Last updated at: 11/7/2024, 11:12:46 AM'),
        ],
      ),
    );
  }

  void _showModifiersBottomSheet(
      List<ModifierModel> modifiers, CartItem cartItem) {
    // Create a list to keep track of selected modifiers
    List<bool> selectedModifiers =
        List.generate(modifiers.length, (index) => false);

    showModalBottomSheet(
      context: context,
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
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Update food modifiers',
                        style: const TextStyle(
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
