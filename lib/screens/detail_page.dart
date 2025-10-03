import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Note Details'),
        centerTitle: true,
      ),
      bottomNavigationBar: !isLandscape ? buildBottomBar(total) : null,
      body: isLandscape
          ? Row(
              children: [
                // LEFT SIDE
                Expanded(
                  flex: 2,
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
                  flex: 1,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Database & Data Structures – Normalization',
                style: TextStyle(
                  fontSize: 18,
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
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPreviewCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.asset(
                  'assets/images/note_preview.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_not_supported, size: 40, color: Colors.black45),
                          SizedBox(height: 8),
                          Text("Preview not available",
                              style: TextStyle(color: Colors.black45)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.menu_book_rounded),
            title: Text('Module'),
            trailing: Text('Database & Data Structures',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.school_rounded),
            title: Text('Level'),
            trailing:
                Text('Level 5', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.apartment_rounded),
            title: Text('School'),
            trailing: Text('School of Computing',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget buildSellerCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 24,
          child: Icon(Icons.person),
        ),
        title: const Text('John Doe',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Verified • Member since 2025'),
      ),
    );
  }

  Widget buildPurchaseCard(double total, double fee) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Purchase Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _priceRow('Material Price', price),
            _priceRow('Platform Fee (5%)', fee),
            const Divider(),
            _priceRow('Total', total, bold: true),
          ],
        ),
      ),
    );
  }

  Widget buildBottomBar(double total) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'LKR ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('Purchase Now'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
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
          Expanded(child: Text(label)),
          Text(
            'LKR ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
