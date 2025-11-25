//   State<Productos> createState() => _ProductosState();
// }

// class _ProductosState extends State<Productos> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   List<Producto> _productos = [];
//   bool _cargando = true;

//   @override
//   void initState() {
//     super.initState();
//     _cargarProductos();
//   }

//   Future<void> _cargarProductos() async {
//     try {
//       final productos = await ProductoService().obtenerProductos();
//       setState(() {
//         _productos = productos;
//         _cargando = false;
//       });
//     } catch (e) {
//       setState(() {
//         _cargando = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error al cargar productos: $e')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5E6D3),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF5E6D3),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E2D)),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         actions: [],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Card(
//             elevation: 8,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(32.0),
//               width: double.infinity,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Seleccione su producto de interés.',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2C3E2D),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   // Campo de búsqueda
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: const Color(0xFFD15113),
//                         width: 2,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _searchController,
//                             decoration: const InputDecoration(
//                               hintText: 'BUSCAR',
//                               hintStyle: TextStyle(
//                                 color: Color(0xFF2C3E2D),
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                             ),
//                             style: const TextStyle(
//                               color: Color(0xFF2C3E2D),
//                               fontSize: 14,
//                             ),
//                             onChanged: (value) {
//                               setState(() {
//                                 _searchQuery = value.toLowerCase();
//                               });
//                             },
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           child: const Icon(
//                             Icons.search,
//                             color: Color(0xFFD15113),
//                             size: 24,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   // Grid de productos
//                   Expanded(
//                     child: _cargando
//                         ? const Center(child: CircularProgressIndicator())
//                         : GridView.count(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 16,
//                             mainAxisSpacing: 16,
//                             childAspectRatio: 0.8, // Ajuste para mostrar imagen mejor
//                             children: _productos
//                                 .where((prod) => _searchQuery.isEmpty || prod.nombreProducto.toLowerCase().contains(_searchQuery))
//                                 .map((prod) => _buildProductCard(prod))
//                                 .toList(),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductCard(Producto producto) {
//     return GestureDetector(
//       onTap: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Seleccionaste: ${producto.nombreProducto}'),
//             backgroundColor: const Color(0xFFD15113),
//           ),
//         );
//         // Aquí puedes navegar a la pantalla de detalles del producto
//         // Navigator.push(context, MaterialPageRoute(builder: (context) => DetalleProducto(producto: producto)));
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF4A4B2F),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Imagen del producto
//             Expanded(
//               flex: 3,
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
//                       ? Image.network(
//                           producto.imagenUrl!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return _buildPlaceholderImage();
//                           },
//                         )
//                       : _buildPlaceholderImage(),
//                 ),
//               ),
//             ),
//             // Información del producto
//             Expanded(
//               flex: 1,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       producto.nombreProducto,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     if (producto.precio != null)
//                       const SizedBox(height: 4),
//                     if (producto.precio != null)
//                       Text(
//                         '\$${producto.precio!.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           color: Color(0xFFD15113),
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaceholderImage() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Center(
//         child: Icon(
//           Icons.image,
//           size: 40,
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }
// }