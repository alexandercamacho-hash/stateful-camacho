import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CartScreen()));

/// A single line in the shopping cart.
class CartItem {
  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });

  final String name;
  final double price;

  /// These two fields change while the app runs, so they are not final.
  int quantity;
  bool gotIt;
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];

  @override
  void initState() {
    super.initState();
    // Preload the three sample items required by the activity.
    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(name: 'Eggs', price: 8.00, quantity: 12, gotIt: true),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  /// Sum of price x quantity for every item in the cart.
  double get _total =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Shopping Cart')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final CartItem item = _items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      'PHP ${item.price.toStringAsFixed(2)} each',
                    ),
                    trailing: Text('x${item.quantity}'),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Total: PHP ${_total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
