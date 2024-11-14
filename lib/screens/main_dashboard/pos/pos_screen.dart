import 'package:flutter/material.dart';
import 'package:pos/utils/app_colors.dart';

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

  // Notes
  TextEditingController kitchenNote = TextEditingController();
  TextEditingController staffNote = TextEditingController();
  TextEditingController paymentNote = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    kitchenNote.dispose();
    staffNote.dispose();
    paymentNote.dispose();
  }

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
                onPressed: () {},
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryItem(
                  'Burgers',
                  'https://gs1ksa.org:5001/uploads/itemImages/1731154705537-burger.png',
                  selectedCategory == 'Burgers',
                ),
                _buildCategoryItem(
                  'Pizza',
                  'https://gs1ksa.org:5001/uploads/itemImages/1731154705537-burger.png',
                  selectedCategory == 'Pizza',
                ),
                _buildCategoryItem(
                  'Salad',
                  'https://gs1ksa.org:5001/uploads/itemImages/1731154705537-burger.png',
                  selectedCategory == 'Salad',
                ),
                _buildCategoryItem(
                  'Spaghetti',
                  'https://gs1ksa.org:5001/uploads/itemImages/1731154705537-burger.png',
                  selectedCategory == 'Spaghetti',
                ),
                // Add more categories as needed
              ],
            ),
          ),
        ),
        // Main content area
        Expanded(
          child: Row(
            children: [
              // Center area - Products grid
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
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: 8, // Replace with actual item count
                          itemBuilder: (context, index) => _buildProductCard(
                            'Product Name',
                            'Product Description',
                            'https://gs1ksa.org:5001/uploads/itemImages/1731154705537-burger.png',
                            '\$9.99',
                          ),
                        ),
                      ),
                      // Pagination controls
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () {},
                                child: const Text('Previous')),
                            TextButton(
                                onPressed: () {}, child: const Text('Next')),
                          ],
                        ),
                      ),
                    ],
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
                                print('Modifier');
                              },
                              onRemove: () {
                                setState(() {
                                  cartItems.removeAt(index);
                                });
                              },
                              image: item.imageUrl,
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

  Widget _buildCategoryItem(String title, String imageUrl, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade800,
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
    String title,
    String description,
    String imageUrl,
    String price,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          cartItems.add(CartItem(
            title: title,
            price: double.parse(price.replaceAll('\$', '')),
            imageUrl: imageUrl,
            quantity: 1,
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
                    image: NetworkImage(imageUrl),
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
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
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
        0, (total, item) => total + (item.price * item.quantity));
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
}

class CartItem {
  final String title;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final String image;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback onModifier;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onModifier,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const Divider(),
                      // modifiers will be displayed here
                      Text(
                        'Modifiers',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // modifier button
                    TextButton(
                      onPressed: onModifier,
                      child: const Text(
                        'Modifier',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                    // remove button
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onRemove,
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quantity controls in a separate row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () => onQuantityChanged(item.quantity - 1),
                  padding: const EdgeInsets.all(4),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => onQuantityChanged(item.quantity + 1),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
