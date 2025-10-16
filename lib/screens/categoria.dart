import 'package:flutter/material.dart';
import 'package:amaranta/Models/categorias.dart';
import 'package:amaranta/Services/categoria_service.dart';
import 'productos_categoria.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<Categoria> categorias = [];
  List<Categoria> categoriasFiltradas = [];
  bool cargando = true;
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    try {
      final data = await CategoriaService().obtenerCategorias();
      setState(() {
        categorias = data;
        categoriasFiltradas = data;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person, color: Color(0xFF2C3E2D)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          cargando
              ? const Center(child: CircularProgressIndicator())
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
                        vertical: 40,
                        horizontal: 24,
                      ),
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                        minHeight: 650,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Elija la categoria de su preferencia.',
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
                              hintText: 'Buscar categoría...',
                              prefixIcon: Icon(
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
                                ), // 1ch aprox
                                borderSide: BorderSide(
                                  color: Color(0xFFD15113),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                borderSide: BorderSide(
                                  color: Color(0xFFD15113),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                borderSide: BorderSide(
                                  color: Color(0xFFD15113),
                                  width: 3,
                                ),
                              ),
                            ),
                            onChanged: (valor) {
                              setState(() {
                                categoriasFiltradas =
                                    categorias
                                        .where(
                                          (cat) => cat.nombreCategoria
                                              .toLowerCase()
                                              .contains(valor.toLowerCase()),
                                        )
                                        .toList();
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 440,
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                              children:
                                  categoriasFiltradas
                                      .map((cat) => _buildCategoryCard(cat))
                                      .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildCategoryCard(Categoria cat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductosPorCategoriaScreen(categoria: cat),
          ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  Text(
                    cat.nombreCategoria,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.descripcion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
