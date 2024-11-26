import 'package:flutter/material.dart';
import 'package:pos/screens/main_dashboard/pos/pos_screen.dart';
import 'package:pos/utils/app_colors.dart';

class CartItemWidget extends StatefulWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback onModifier;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onModifier,
  });

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  @override
  Widget build(BuildContext context) {
    // Calculate total price including modifiers
    double modifiersTotal = widget.item.selectedModifiers.fold(
      0.0,
      (total, modifier) => total + modifier.price,
    );

    double totalPrice =
        (widget.item.menuItem.price * widget.item.quantity) + modifiersTotal;

    double itemPrice = widget.item.menuItem.price * widget.item.quantity;

    double oneItemPrice = widget.item.menuItem.price;

    double oneItemPricePlusModifiers = oneItemPrice + modifiersTotal;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    widget.item.menuItem.image,
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
                        widget.item.menuItem.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${widget.item.menuItem.price.toStringAsFixed(2)} - Item price',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      modifiersTotal > 0.00
                          ? Text(
                              '\$${modifiersTotal.toStringAsFixed(2)} - ${widget.item.selectedModifiers.map((modifier) => modifier.name).join(', ')}', // Show total price
                              style: TextStyle(color: Colors.grey.shade600),
                            )
                          : Container(),
                      if (modifiersTotal > 0) ...[
                        Text(
                          'Item price + modifiers: \$${oneItemPricePlusModifiers.toStringAsFixed(2)}', // Show modifiers total
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          'Total: \$${totalPrice.toStringAsFixed(2)}', // Show modifiers total
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const Divider(),
                      // Display selected modifiers
                      if (widget.item.selectedModifiers.isNotEmpty) ...[
                        Text(
                          'Modifiers:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              widget.item.selectedModifiers.map((modifier) {
                            return Text(
                              modifier.name,
                              style: TextStyle(color: Colors.grey.shade600),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Text(
                          'No modifiers selected',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    // modifier button
                    TextButton(
                      onPressed: widget.onModifier,
                      child: const Text(
                        'Modifier',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                    // remove button
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: widget.onRemove,
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Quantity controls in a separate row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: () =>
                      widget.onQuantityChanged(widget.item.quantity - 1),
                  padding: const EdgeInsets.all(2),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.item.quantity}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () =>
                      widget.onQuantityChanged(widget.item.quantity + 1),
                  padding: const EdgeInsets.all(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
