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
        final args = settings.arguments as ProductScreenDetailArguments;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: args.product),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Center(child: Text('Rota não encontrada!'))),
        );
    }
  }
}

class ProductScreenDetailArguments {
  final Product product;
  ProductScreenDetailArguments(this.product);
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
    setState(() {
      lastViewed = product;
    });
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.details,
      arguments: ProductScreenDetailArguments(product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  Icon(Icons.history, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    "Último item visto",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            LastViewedCard(
              product: lastViewed,
              onTap: () async {
                _openDetails(lastViewed!);
              },
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  Icon(
                    Icons.local_fire_department,
                    size: 18,
                    color: Colors.red,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Em alta",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (ctx, index) {
                  final p = products[index];
                  return ProductCard(
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
      ),
      appBar: AppBar(
        title: Text("Produtos"),
        backgroundColor: Colors.grey,
        centerTitle: true,
      ),
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
      return SizedBox.shrink(child: Text("Nenhum produto!"));
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            product!.imagem,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          product!.nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          product!.descricao,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        onTap: onTap,
      ),
    );
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
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  product.imagem,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// TELA DE DETALHES
// ---------------------------
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.nome,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  product.imagem,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.nome,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "R\$ ${product.preco.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.descricao,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
