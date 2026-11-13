import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Mini Shopping Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F6E73)),
        scaffoldBackgroundColor: const Color(0xFFF4F7F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F6E73),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const CartScreen(),
    ),
  );
}

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
  static const int _minQuantity = 1;
  static const int _maxQuantity = 99;

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

  /// The parent owns the data, so every change happens inside setState().
  void _increase(int index) {
    setState(() {
      if (_items[index].quantity < _maxQuantity) {
        _items[index].quantity++;
      }
    });
  }

  void _decrease(int index) {
    setState(() {
      if (_items[index].quantity > _minQuantity) {
        _items[index].quantity--;
      }
    });
  }

  void _toggle(int index) {
    setState(() {
      _items[index].gotIt = !_items[index].gotIt;
    });
  }

  /// Sum of price x quantity for every item in the cart.
  double get _total =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  int get _gotItCount => _items.where((item) => item.gotIt).length;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mini Shopping Cart')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _items.isEmpty
                  ? const _EmptyCart()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final CartItem item = _items[index];
                        return CartItemTile(
                          item: item,
                          onIncrease: () => _increase(index),
                          onDecrease: () => _decrease(index),
                          onToggle: () => _toggle(index),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Items: ${_items.length}  •  Got it: $_gotItCount',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                    ),
                    Text(
                      'Total: PHP ${_total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stateless row for one cart item.
///
/// It displays the item it is given and reports taps through callbacks.
/// It never calls setState(); the parent State is the single source of truth.
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggle;

  static const int _minQuantity = 1;
  static const int _maxQuantity = 99;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool checked = item.gotIt;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (_) => onToggle(),
              semanticLabel: 'Mark ${item.name} as got it',
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: checked
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    'PHP ${item.price.toStringAsFixed(2)} each',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.outlined(
              onPressed: item.quantity > _minQuantity ? onDecrease : null,
              tooltip: 'Decrease quantity',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 36,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton.outlined(
              onPressed: item.quantity < _maxQuantity ? onIncrease : null,
              tooltip: 'Increase quantity',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

/// Friendly placeholder shown when no items are left in the cart.
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 56,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text('Your cart is empty', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Add an item below to get started.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
