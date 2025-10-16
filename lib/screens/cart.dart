import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amaranta/Models/cart.dart';
import 'checkout.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartModel.instance;
    return ChangeNotifierProvider.value(
      value: cart,
      child: Scaffold(
        appBar: AppBar(title: const Text('Carrito')),
        body: Consumer<CartModel>(
          builder: (context, model, _) {
            if (model.items.isEmpty) {
              return const Center(child: Text('El carrito está vacío'));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: model.items.length,
                    itemBuilder: (context, index) {
                      final item = model.items[index];
                      return ListTile(
                        leading:
                            item.product.imagenUrl != null
                                ? Image.network(
                                  item.product.imagenUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(Icons.image),
                        title: Text(item.product.nombreProducto),
                        subtitle: Text(
                          'Unit: \$${item.unitPrice.toStringAsFixed(2)}  |  Total: \$${item.total.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => model.removeOne(item.product),
                            ),
                            Text(item.quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => model.addProduct(item.product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: \$${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD15113),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Realizar pedido'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
