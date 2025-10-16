class OrderItem {
  final int? codigoProducto;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  OrderItem({
    this.codigoProducto,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  }) : subtotal = cantidad * precioUnitario;

  Map<String, dynamic> toJson() => {
    'codigoProducto': codigoProducto,
    'nombreProducto': nombreProducto,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
    'subtotal': subtotal,
  };
}

class Order {
  final int? codigoPedido;
  final String fechaPedido; // ISO date or string
  final double precioTotal;
  final String estado;
  final int idCliente;
  final String nombreCliente;
  final List<OrderItem> detalles;

  Order({
    this.codigoPedido,
    required this.fechaPedido,
    required this.precioTotal,
    required this.estado,
    required this.idCliente,
    required this.nombreCliente,
    required this.detalles,
  });

  Map<String, dynamic> toJson() => {
    if (codigoPedido != null) 'codigoPedido': codigoPedido,
    'fechaPedido': fechaPedido,
    'precioTotal': precioTotal,
    'estado': estado,
    'idCliente': idCliente,
    'nombreCliente': nombreCliente,
    'detalles': detalles.map((d) => d.toJson()).toList(),
  };

  /// Create from cart items and cliente info
  static Order fromCart({
    int? codigoPedido,
    required int idCliente,
    required String nombreCliente,
    required List<dynamic> cartItems,
    required String fechaPedido,
    required String estado,
  }) {
    final detalles =
        cartItems.map((ci) {
          // ci is CartItem
          try {
            final producto = (ci as dynamic).product;
            final cantidad = (ci as dynamic).quantity as int;
            return OrderItem(
              codigoProducto: producto.codigoProducto,
              nombreProducto: producto.nombreProducto,
              cantidad: cantidad,
              precioUnitario: producto.precio ?? 0.0,
            );
          } catch (_) {
            // fallback if cart item is a map
            final nombre = ci['nombreProducto'] ?? ci['nombre'] ?? '';
            final cantidad = ci['cantidad'] ?? ci['quantity'] ?? 1;
            final precio =
                (ci['precioUnitario'] ?? ci['precio'] ?? 0).toDouble();
            return OrderItem(
              nombreProducto: nombre,
              cantidad: cantidad,
              precioUnitario: precio,
            );
          }
        }).toList();

    final total = detalles.fold<double>(0.0, (s, d) => s + d.subtotal);

    return Order(
      codigoPedido: codigoPedido,
      fechaPedido: fechaPedido,
      precioTotal: total,
      estado: estado,
      idCliente: idCliente,
      nombreCliente: nombreCliente,
      detalles: detalles,
    );
  }
}
