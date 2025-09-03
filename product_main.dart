import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ---------------------------
// ROTAS
// ---------------------------
class AppRoutes {
  static const home = '/';
  static const details = '/details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => ProductListScreen());
      case details:
        return MaterialPageRoute(builder: (_) => ProductDetailScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Center(child: Text('Rota não encontrada!'))),
        );
    }
  }

}

// ---------------------------
// MODELO DE PRODUTO
// ---------------------------
class Product {
  // TODO

}

// ---------------------------
// APP PRINCIPAL
// ---------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: retornar MaterialApp usando AppRoutes.routes
    return MaterialApp(
      title: "Produtos",
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------------------------
// TELA DE LISTA
// ---------------------------
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  Product? lastViewed;

  @override
  void initState() {
    super.initState();
    // TODO
  }

  Future<void> _loadProducts() async {
    // TODO: carregar JSON de assets/data/products.json e preencher lista products
  }

  Future<void> _loadLastViewed() async {
    // TODO: carregar último produto visto de SharedPreferences
  }

  Future<void> _saveLastViewed(Product product) async {
    // TODO: salvar produto em SharedPreferences
  }

  void _openDetails(Product product) async {
    // TODO: abrir ProductDetailScreen via Navigator e salvar como último visto
  }

  @override
  Widget build(BuildContext context) {
    // TODO: montar Scaffold com AppBar, seção "Último produto visto" e lista de produtos
    return Container();
  }
}

// ---------------------------
// WIDGET: CARD ÚLTIMO PRODUTO
// ---------------------------
class LastViewedCard extends StatelessWidget {
  final Product? product;
  final VoidCallback? onTap;

  const LastViewedCard({super.key, this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    // TODO: retornar Card com informações do último produto ou SizedBox.shrink() se null
    return Container();
  }
}

// ---------------------------
// WIDGET: CARD PRODUTO
// ---------------------------
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    // TODO: retornar Card/ListTile com nome, imagem, descrição do produto
    return Container();
  }
}

// ---------------------------
// TELA DE DETALHES
// ---------------------------
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: recuperar produto via ModalRoute e exibir detalhes (imagem, nome, estrelas, descrição e preços)
    return Container();
  }
}
