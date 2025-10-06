import 'package:flutter/material.dart';
import 'package:studybuddy/screens/CartPage.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  bool _descExpanded = false;

  final Color primary = const Color(0xFF006644);
  final double price = 850.00;

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

  /* ----------------- Widgets ----------------- */

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
                'Database & Data Structures – Normalization',
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
              firstChild: const Text(
                'This comprehensive study material explains normalization with clear, real-world tables and step-by-step transformations (1NF → 2NF → 3NF).',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: const Text(
                'This comprehensive study material explains normalization with clear, real-world tables and step-by-step transformations (1NF → 2NF → 3NF).\n\nIt includes:\n• Examples with invoice, product, and customer tables\n• Composite primary key explanations\n• Practice problems and exam tips',
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
              'Database & Data Structures',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.school_rounded, color: primary),
            title: Text('Level', style: Theme.of(context).textTheme.bodyMedium),
            trailing: Text(
              'Level 5',
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
              'School of Computing',
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
    // Create a product map similar to ExplorePage
    final product = {
      'title': 'Database & Data Structures – Normalization',
      'description':
          'Comprehensive study material with clear examples and step-by-step transformations',
      'price': 'LKR ${price.toStringAsFixed(2)}',
      'rating': 4.8,
      'level': 'Level 5',
    };

    // Add to cart using CartManager
    CartManager().addItem(product, 'Computing');

    // Show success message
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
