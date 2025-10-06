import 'package:flutter/material.dart';
import 'package:studybuddy/screens/CartPage.dart';
import 'package:studybuddy/screens/detail_page.dart';

const kBrandGreen = Color(0xFF006644);

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String selectedCategory = 'Computing';


  final Map<String, List<Map<String, dynamic>>> categoryProducts = {
    'Computing': [
      {
        'title': 'Database Systems & Data Structures',
        'description': 'Complete guide to DBMS and algorithms',
        'price': 'LKR 850.00',
        'rating': 4.8,
        'level': 'Level 5',
      },
      {
        'title': 'Web Development Fundamentals',
        'description': 'HTML, CSS, JavaScript & Frameworks',
        'price': 'LKR 800.00',
        'rating': 4.9,
        'level': 'Level 4',
      },
      {
        'title': 'Mobile Application Development',
        'description': 'Flutter & React Native Development',
        'price': 'LKR 350.00',
        'rating': 4.7,
        'level': 'Level 6',
      },
      {
        'title': 'Server-side Authentication Techniques',
        'description': 'Security and backend development',
        'price': 'LKR 750.00',
        'rating': 4.6,
        'level': 'Level 5',
      },
      {
        'title': 'Software Engineering Principles',
        'description': 'SDLC, Testing & Project Management',
        'price': 'LKR 450.00',
        'rating': 4.5,
        'level': 'Level 4',
      },
    ],
    'Business': [
      {
        'title': 'Business Management Fundamentals',
        'description': 'Strategic planning and operations',
        'price': 'LKR 600.00',
        'rating': 4.4,
        'level': 'Level 4',
      },
      {
        'title': 'Financial Accounting & Analysis',
        'description': 'Complete accounting principles',
        'price': 'LKR 700.00',
        'rating': 4.7,
        'level': 'Level 5',
      },
      {
        'title': 'Marketing & Digital Strategy',
        'description': 'Modern marketing techniques',
        'price': 'LKR 550.00',
        'rating': 4.6,
        'level': 'Level 4',
      },
      {
        'title': 'Human Resource Management',
        'description': 'HR policies and management',
        'price': 'LKR 480.00',
        'rating': 4.3,
        'level': 'Level 5',
      },
    ],
    'Law': [
      {
        'title': 'Constitutional Law Principles',
        'description': 'Fundamental rights and duties',
        'price': 'LKR 900.00',
        'rating': 4.8,
        'level': 'Level 5',
      },
      {
        'title': 'Contract Law & Agreements',
        'description': 'Legal contracts and obligations',
        'price': 'LKR 750.00',
        'rating': 4.6,
        'level': 'Level 4',
      },
      {
        'title': 'Criminal Law & Procedure',
        'description': 'Criminal justice system',
        'price': 'LKR 850.00',
        'rating': 4.7,
        'level': 'Level 6',
      },
      {
        'title': 'Corporate & Commercial Law',
        'description': 'Business law and regulations',
        'price': 'LKR 800.00',
        'rating': 4.5,
        'level': 'Level 5',
      },
    ],
  };

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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(60, 40),
                padding: const EdgeInsets.all(8),
              ),
              child: const Icon(Icons.shopping_cart),
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
          color: isSelected ? kBrandGreen : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? kBrandGreen : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kBrandGreen.withOpacity(0.3),
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
                color: isSelected ? Colors.white : Colors.black87,
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteDetailPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                    colors: [kBrandGreen.withOpacity(0.8), kBrandGreen],
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['description'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          product['rating'].toString(),
                          style: const TextStyle(fontSize: 12),
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
                    product['price'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kBrandGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Add item to cart using CartManager
                      CartManager().addItem(product, selectedCategory);

                      // Show confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product['title']} added to cart!'),
                          backgroundColor: kBrandGreen,
                          duration: const Duration(seconds: 1),
                        ),
                      );

                      // Navigate to CartPage after a short delay
                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(60, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
