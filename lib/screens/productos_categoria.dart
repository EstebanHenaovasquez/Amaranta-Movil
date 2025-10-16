import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amaranta/Models/cart.dart';
import 'package:amaranta/Models/producto.dart';
import 'package:amaranta/Models/categorias.dart';
import 'package:amaranta/Services/producto_service.dart';
import 'package:amaranta/screens/cart.dart';
import 'package:amaranta/screens/orders.dart';
import 'package:amaranta/Services/pending_order_service.dart';

class ProductosPorCategoriaScreen extends StatefulWidget {
  final Categoria categoria;

  const ProductosPorCategoriaScreen({super.key, required this.categoria});

  @override
  State<ProductosPorCategoriaScreen> createState() =>
      _ProductosPorCategoriaScreenState();
}

class _ProductosPorCategoriaScreenState
    extends State<ProductosPorCategoriaScreen> {
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];
  bool cargando = true;
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    try {
      final todos = await ProductoService().obtenerProductos();
      setState(() {
        productos =
            todos
                .where((p) => p.idCategoria == widget.categoria.idCategoria)
                .toList();
        productosFiltrados = productos;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: CartModel.instance,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5E6D3),
        appBar: AppBar(
          title: Text(widget.categoria.nombreCategoria),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            FutureBuilder<int>(
              future: PendingOrderService.getAllPending().then(
                (list) => list.length,
              ),
              builder: (context, snapshot) {
                final pendingCount = snapshot.data ?? 0;
                return Row(
                  children: [
                    IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.black),
                          Consumer<CartModel>(
                            builder: (context, cart, _) {
                              if (cart.totalItems <= 0) return const SizedBox();
                              return Positioned(
                                right: -6,
                                top: -6,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    cart.totalItems.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.list_alt, color: Colors.black),
                          if (pendingCount > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  pendingCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrdersScreen(),
                            ),
                          ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body:
            cargando
                ? const Center(child: CircularProgressIndicator())
                : productos.isEmpty
                ? const Center(
                  child: Text('No hay productos en esta categoría.'),
                )
                : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxWidth: 800,
                          minHeight: 400,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Elija el producto de su preferencia.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                color: Color(0xFF2C3E2D),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _busquedaController,
                              decoration: InputDecoration(
                                hintText: 'Buscar producto...',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF2C3E2D),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD15113),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD15113),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD15113),
                                    width: 3,
                                  ),
                                ),
                              ),
                              onChanged: (valor) {
                                setState(() {
                                  productosFiltrados =
                                      productos
                                          .where(
                                            (prod) => prod.nombreProducto
                                                .toLowerCase()
                                                .contains(valor.toLowerCase()),
                                          )
                                          .toList();
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 520,
                              child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                                children:
                                    productosFiltrados
                                        .map(_buildProductCard)
                                        .toList(),
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

  Widget _buildProductCard(Producto producto) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seleccionaste: ${producto.nombreProducto}')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4A4B2F),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                height: 90,
                child:
                    producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                        ? Image.network(producto.imagenUrl!, fit: BoxFit.cover)
                        : _buildPlaceholder(),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    producto.nombreProducto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (producto.precio != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        '\$${producto.precio!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Consumer<CartModel>(
                    builder: (context, cart, _) {
                      return SizedBox(
                        width: 140,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Agregar'),
                          onPressed: () => cart.addProduct(producto),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD15113),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(child: Icon(Icons.image, size: 40, color: Colors.grey));
  }
}
