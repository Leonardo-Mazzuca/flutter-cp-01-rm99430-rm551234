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
  final int id;
  final String nome;
  final int preco;
  final String descricao;
  final String imagem;

  Product({
    required this.id,
    required this.nome,
    required this.preco,
    required this.descricao,
    required this.imagem,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nome: json['nome'],
      imagem: json['imagem'],
      preco: json['preco'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'imagem': imagem,
    'preco': preco,
    'descricao': descricao,
  };
}

// ---------------------------
// APP PRINCIPAL
// ---------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  static const _keyRecentProducts = 'RecentProducts';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadLastViewed();
  }

  Future<void> _loadProducts() async {
    String jsonPath = 'assets/data/products.json';
    final jsonString = await rootBundle.loadString(jsonPath);
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      products = jsonList.map((json) => Product.fromJson(json)).toList();
    });
  }

  Future<void> _loadLastViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyRecentProducts);

    if (jsonStr == null) return;

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      setState(() {
        lastViewed = Product.fromJson(map);
      });
    } catch (_) {
      setState(() {
        lastViewed = null;
      });
    }
  }

  Future<void> _saveLastViewed(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRecentProducts, jsonEncode(product.toJson()));
  }

  void _openDetails(Product product) async {
    await _saveLastViewed(product);
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.details);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Produto visto recentemente"),
          LastViewedCard(
            product: lastViewed,
            onTap: () async {
              _openDetails(lastViewed!);
            },
          ),
          SizedBox(height: 10),
          Text("Lista de produtos"),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (ctx, index) {
                final p = products[index];
                ProductCard(
                  product: p,
                  onTap: () async {
                    _openDetails(p);
                  },
                );
              },
            ),
          ),
        ],
      ),
      appBar: AppBar(title: Text("Produtos")),
    );
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
    if (product == null) {
      return SizedBox.shrink(
        child: Text("Nenhum produto!"),
      );
    }
    return ProductCard(product: product!, onTap: onTap);
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
    return ListTile(
      title: Text(product.nome),
      subtitle: Text(product.descricao),
      leading: Image.asset(product.imagem),
      onTap: onTap,
    );
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
