import 'package:flutter/material.dart';
import 'package:pos/screens/main_dashboard/pos/pos_screen.dart';
import 'package:pos/utils/app_colors.dart';

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
