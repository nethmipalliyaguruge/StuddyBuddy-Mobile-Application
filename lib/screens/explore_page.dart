import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/cart_provider.dart';
import 'package:studybuddy/providers/materials_provider.dart';
import 'package:studybuddy/models/material.dart';
import 'package:studybuddy/screens/cart_page.dart';
import 'package:studybuddy/screens/detail_page.dart';
import 'package:studybuddy/utils/constants.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String selectedCategory = 'Computing';

  // Fallback data when API is not available
  final Map<String, List<Map<String, dynamic>>> categoryProducts = {
    'Computing': [
      {
        'id': 1,
        'title': 'Database Systems & Data Structures',
        'description': 'Complete guide to DBMS and algorithms',
        'price': 850.00,
        'rating': 4.8,
        'level': 'Level 5',
      },
      {
        'id': 2,
        'title': 'Web Development Fundamentals',
        'description': 'HTML, CSS, JavaScript & Frameworks',
        'price': 800.00,
        'rating': 4.9,
        'level': 'Level 4',
      },
      {
        'id': 3,
        'title': 'Mobile Application Development',
        'description': 'Flutter & React Native Development',
        'price': 350.00,
        'rating': 4.7,
        'level': 'Level 6',
      },
      {
        'id': 4,
        'title': 'Server-side Authentication Techniques',
        'description': 'Security and backend development',
        'price': 750.00,
        'rating': 4.6,
        'level': 'Level 5',
      },
      {
        'id': 5,
        'title': 'Software Engineering Principles',
        'description': 'SDLC, Testing & Project Management',
        'price': 450.00,
        'rating': 4.5,
        'level': 'Level 4',
      },
    ],
    'Business': [
      {
        'id': 6,
        'title': 'Business Management Fundamentals',
        'description': 'Strategic planning and operations',
        'price': 600.00,
        'rating': 4.4,
        'level': 'Level 4',
      },
      {
        'id': 7,
        'title': 'Financial Accounting & Analysis',
        'description': 'Complete accounting principles',
        'price': 700.00,
        'rating': 4.7,
        'level': 'Level 5',
      },
      {
        'id': 8,
        'title': 'Marketing & Digital Strategy',
        'description': 'Modern marketing techniques',
        'price': 550.00,
        'rating': 4.6,
        'level': 'Level 4',
      },
      {
        'id': 9,
        'title': 'Human Resource Management',
        'description': 'HR policies and management',
        'price': 480.00,
        'rating': 4.3,
        'level': 'Level 5',
      },
    ],
    'Law': [
      {
        'id': 10,
        'title': 'Constitutional Law Principles',
        'description': 'Fundamental rights and duties',
        'price': 900.00,
        'rating': 4.8,
        'level': 'Level 5',
      },
      {
        'id': 11,
        'title': 'Contract Law & Agreements',
        'description': 'Legal contracts and obligations',
        'price': 750.00,
        'rating': 4.6,
        'level': 'Level 4',
      },
      {
        'id': 12,
        'title': 'Criminal Law & Procedure',
        'description': 'Criminal justice system',
        'price': 850.00,
        'rating': 4.7,
        'level': 'Level 6',
      },
      {
        'id': 13,
        'title': 'Corporate & Commercial Law',
        'description': 'Business law and regulations',
        'price': 800.00,
        'rating': 4.5,
        'level': 'Level 5',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    // Fetch materials from API when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialsProvider>().fetchMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Explore Categories',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Stack(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kBrandGreen,
                        minimumSize: const Size(60, 40),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: const Icon(Icons.shopping_cart),
                    ),
                    if (cartProvider.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            cartProvider.itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        backgroundColor: kBrandGreen,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          buildCategoryTabs(),
          Expanded(child: buildProductList()),
        ],
      ),
    );
  }

  Widget buildCategoryTabs() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          buildCategoryTab('Computing', Icons.computer, Colors.blue),
          buildCategoryTab('Business', Icons.business, Colors.orange),
          buildCategoryTab('Law', Icons.gavel, Colors.red),
        ],
      ),
    );
  }

  Widget buildCategoryTab(String category, IconData icon, Color color) {
    bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kBrandGreen : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? kBrandGreen : Theme.of(context).dividerColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kBrandGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductList() {
    List<Map<String, dynamic>> products =
        categoryProducts[selectedCategory] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return buildProductCard(products[index]);
      },
    );
  }

  Widget buildProductCard(Map<String, dynamic> product) {
    final cartProvider = context.watch<CartProvider>();
    final isInCart = cartProvider.isInCart(product['id'] as int);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NoteDetailPage(product: product, category: selectedCategory),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kBrandGreen.withValues(alpha: 0.8), kBrandGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.book, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            product['level'],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          product['rating'].toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Add Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LKR ${(product['price'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kBrandGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: isInCart
                        ? null
                        : () {
                            _addToCart(product);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCart ? Colors.grey : kBrandGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(60, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isInCart ? 'Added' : 'Add',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    // Create a StudyMaterial from the product data
    final material = StudyMaterial(
      id: product['id'] as int,
      userId: 0,
      moduleId: 0,
      title: product['title'] as String,
      description: product['description'] as String?,
      price: product['price'] as double,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<CartProvider>().addItem(material);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product['title']} added to cart!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: kBrandGreen,
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
        ),
      ),
    );
  }
}
