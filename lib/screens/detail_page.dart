import 'package:flutter/material.dart';
import 'package:studybuddy/screens/CartPage.dart';

class NoteDetailPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  final String? category;

  const NoteDetailPage({super.key, this.product, this.category});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  bool _descExpanded = false;

  final Color primary = const Color(0xFF006644);

  // Get product-specific data with fallbacks
  String get productTitle => widget.product?['title'] ?? 'Database & Data Structures - Normalization';
  String get productCategory => widget.category ?? 'Computing';
  String get productLevel => widget.product?['level'] ?? 'Level 5';
  double get productRating => (widget.product?['rating'] ?? 4.8).toDouble();

  double get price {
    if (widget.product?['price'] != null) {
      String priceStr = widget.product!['price']
          .toString()
          .replaceAll('LKR ', '')
          .replaceAll(',', '');
      return double.tryParse(priceStr) ?? 850.00;
    }
    return 850.00;
  }

  // Get product-specific descriptions and details
  Map<String, dynamic> get productDetails {
    switch (productTitle) {
      case 'Database Systems & Data Structures':
        return {
          'description':
              'This comprehensive study material covers database management systems and data structures with practical examples. Includes normalization techniques, SQL queries, B-trees, hash tables, and sorting algorithms.',
          'fullDescription':
              'This comprehensive study material covers database management systems and data structures with practical examples.\n\nIt includes:\n• Database normalization (1NF, 2NF, 3NF, BCNF)\n• SQL query optimization techniques\n• Data structures: Arrays, Linked Lists, Stacks, Queues\n• Trees: Binary Trees, B-trees, AVL Trees\n• Hash tables and collision resolution\n• Sorting and searching algorithms\n• Time and space complexity analysis',
          'module': 'Database & Data Structures',
          'school': 'School of Computing',
        };
      case 'Web Development Fundamentals':
        return {
          'description':
              'Complete guide to modern web development covering HTML5, CSS3, JavaScript ES6+, and popular frameworks like React and Angular.',
          'fullDescription':
              'Complete guide to modern web development covering HTML5, CSS3, JavaScript ES6+, and popular frameworks.\n\nIt includes:\n• HTML5 semantic elements and accessibility\n• CSS3 flexbox, grid, and animations\n• JavaScript ES6+ features and async programming\n• React.js components and state management\n• RESTful API integration\n• Responsive design principles\n• Web performance optimization',
          'module': 'Web Development',
          'school': 'School of Computing',
        };
      case 'Mobile Application Development':
        return {
          'description':
              'Learn mobile app development using Flutter and React Native with hands-on projects and real-world examples.',
          'fullDescription':
              'Learn mobile app development using Flutter and React Native with hands-on projects and real-world examples.\n\nIt includes:\n• Flutter widgets and state management\n• React Native components and navigation\n• Cross-platform development strategies\n• Native device API integration\n• App store deployment processes\n• Performance optimization techniques\n• Testing and debugging mobile apps',
          'module': 'Mobile Development',
          'school': 'School of Computing',
        };
      case 'Constitutional Law Principles':
        return {
          'description':
              'Comprehensive study of constitutional law covering fundamental rights, separation of powers, and constitutional interpretation.',
          'fullDescription':
              'Comprehensive study of constitutional law covering fundamental rights, separation of powers, and constitutional interpretation.\n\nIt includes:\n• Fundamental rights and liberties\n• Constitutional interpretation methods\n• Separation of powers doctrine\n• Judicial review principles\n• Constitutional amendments process\n• Landmark constitutional cases\n• Federal vs state constitutional law',
          'module': 'Constitutional Law',
          'school': 'School of Law',
        };
      case 'Business Management Fundamentals':
        return {
          'description':
              'Essential business management concepts including strategic planning, organizational behavior, and leadership principles.',
          'fullDescription':
              'Essential business management concepts including strategic planning, organizational behavior, and leadership principles.\n\nIt includes:\n• Strategic planning and analysis\n• Organizational structure and design\n• Leadership styles and effectiveness\n• Team management and motivation\n• Decision-making processes\n• Performance management systems\n• Change management strategies',
          'module': 'Business Management',
          'school': 'School of Business',
        };
      case 'Server-side Authentication Techniques':
        return {
          'description':
              'Advanced security concepts covering authentication, authorization, and secure backend development practices.',
          'fullDescription':
              'Advanced security concepts covering authentication, authorization, and secure backend development practices.\n\nIt includes:\n• JWT token implementation\n• OAuth 2.0 and OpenID Connect\n• Session management strategies\n• Password hashing and salting\n• Multi-factor authentication\n• API security best practices\n• Vulnerability assessment',
          'module': 'Backend Security',
          'school': 'School of Computing',
        };
      case 'Software Engineering Principles':
        return {
          'description':
              'Fundamental software engineering practices including SDLC methodologies, testing strategies, and project management.',
          'fullDescription':
              'Fundamental software engineering practices including SDLC methodologies, testing strategies, and project management.\n\nIt includes:\n• Software development lifecycle models\n• Agile and Scrum methodologies\n• Version control with Git\n• Unit and integration testing\n• Code review processes\n• Project estimation techniques\n• Software architecture patterns',
          'module': 'Software Engineering',
          'school': 'School of Computing',
        };
      case 'Financial Accounting & Analysis':
        return {
          'description':
              'Comprehensive accounting principles covering financial statements, ratio analysis, and managerial accounting concepts.',
          'fullDescription':
              'Comprehensive accounting principles covering financial statements, ratio analysis, and managerial accounting concepts.\n\nIt includes:\n• Balance sheet preparation\n• Income statement analysis\n• Cash flow statement interpretation\n• Financial ratio calculations\n• Cost accounting principles\n• Budgeting and forecasting\n• Internal controls and auditing',
          'module': 'Financial Accounting',
          'school': 'School of Business',
        };
      case 'Contract Law & Agreements':
        return {
          'description':
              'Essential contract law principles covering formation, performance, breach, and remedies in commercial transactions.',
          'fullDescription':
              'Essential contract law principles covering formation, performance, breach, and remedies in commercial transactions.\n\nIt includes:\n• Contract formation elements\n• Offer and acceptance rules\n• Consideration requirements\n• Contract performance standards\n• Breach of contract remedies\n• Commercial sales law\n• International contract principles',
          'module': 'Contract Law',
          'school': 'School of Law',
        };
      case 'Criminal Law & Procedure':
        return {
          'description':
              'Comprehensive study of criminal law elements, defenses, and procedural requirements in the justice system.',
          'fullDescription':
              'Comprehensive study of criminal law elements, defenses, and procedural requirements in the justice system.\n\nIt includes:\n• Elements of criminal offenses\n• Criminal defenses and justifications\n• Constitutional criminal procedure\n• Evidence rules and admissibility\n• Sentencing guidelines\n• Appellate process procedures\n• Victims\' rights and protections',
          'module': 'Criminal Law',
          'school': 'School of Law',
        };
      default:
        return {
          'description':
              'Comprehensive study material with detailed explanations and practical examples.',
          'fullDescription':
              'Comprehensive study material with detailed explanations and practical examples.\n\nIt includes:\n• Core concepts and principles\n• Practical applications\n• Case studies and examples\n• Assessment preparation\n• Additional resources and references',
          'module': productTitle.split(' ').take(3).join(' '),
          'school': _getSchoolByCategory(productCategory),
        };
    }
  }

  String _getSchoolByCategory(String category) {
    switch (category) {
      case 'Computing':
        return 'School of Computing';
      case 'Business':
        return 'School of Business';
      case 'Law':
        return 'School of Law';
      default:
        return 'School of Computing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fee = price * 0.05;
    final total = price + fee;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text('Note Details'), centerTitle: true),
      bottomNavigationBar: !isLandscape ? buildBottomBar(total) : null,
      body: isLandscape
          ? Row(
              children: [
                // LEFT SIDE
                Expanded(
                  flex: 3,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      buildTitleAndPrice(),
                      buildPreviewCard(),
                      buildDescriptionCard(),
                    ],
                  ),
                ),

                // RIGHT SIDE
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      buildModuleCard(),
                      buildSellerCard(),
                      buildPurchaseCard(total, fee),
                      const SizedBox(height: 12),
                      buildBottomBar(total),
                    ],
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                buildTitleAndPrice(),
                buildPreviewCard(),
                buildDescriptionCard(),
                buildModuleCard(),
                buildSellerCard(),
                buildPurchaseCard(total, fee),
                const SizedBox(height: 120),
              ],
            ),
    );
  }



  Widget buildTitleAndPrice() {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                productTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'LKR 850.00',
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPreviewCard() {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.asset(
                  'assets/images/note_preview.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).cardColor,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Preview not available",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.5),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDescriptionCard() {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _descExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                productDetails['description'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              secondChild: Text(
                productDetails['fullDescription'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _descExpanded = !_descExpanded),
              icon: Icon(
                _descExpanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: Text(_descExpanded ? 'See less' : 'See more'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildModuleCard() {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.menu_book_rounded, color: primary),
            title: Text(
              'Module',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Text(
              productDetails['module'],
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.school_rounded, color: primary),
            title: Text('Level', style: Theme.of(context).textTheme.bodyMedium),
            trailing: Text(
              productLevel,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.apartment_rounded, color: primary),
            title: Text(
              'School',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Text(
              productDetails['school'],
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSellerCard() {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: primary.withOpacity(0.1),
          child: Icon(Icons.person, color: primary),
        ),
        title: Text(
          'John Doe',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Verified • Member since 2025',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget buildPurchaseCard(double total, double fee) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Purchase Details',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            isLandscape
                ? Column(
                    children: [
                      _priceRow('Material Price', price),
                      _priceRow('Platform Fee (5%)', fee),
                      const Divider(),
                      _priceRow('Total', total, bold: true),
                    ],
                  )
                : Column(
                    children: [
                      _priceRow('Material Price', price),
                      _priceRow('Platform Fee (5%)', fee),
                      const Divider(),
                      _priceRow('Total', total, bold: true),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomBar(double total) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'LKR ${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Purchase feature coming soon!',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: primary,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Purchase Now'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                _addToCart();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary),
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Cart'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            'LKR ${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    final product = {
      'title': productTitle,
      'description': productDetails['description'],
      'price': 'LKR ${price.toStringAsFixed(2)}',
      'rating': productRating,
      'level': productLevel,
    };

    // Add to cart using CartManager
    CartManager().addItem(product, productCategory);


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Added to cart successfully!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primary,
        duration: const Duration(seconds: 2),
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
