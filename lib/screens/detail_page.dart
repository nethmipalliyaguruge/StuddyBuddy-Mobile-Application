import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/cart_provider.dart';
import 'package:studybuddy/providers/materials_provider.dart';
import 'package:studybuddy/models/material.dart';
import 'package:studybuddy/screens/cart_page.dart';
import 'package:studybuddy/services/api_service.dart';
import 'package:studybuddy/providers/recently_viewed_provider.dart';
import 'package:studybuddy/utils/constants.dart';

class NoteDetailPage extends StatefulWidget {
  final int? materialId;
  final Map<String, dynamic>? product;
  final String? category;

  const NoteDetailPage({
    super.key,
    this.materialId,
    this.product,
    this.category,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  bool _descExpanded = false;
  StudyMaterial? _material;
  bool _isLoading = false;
  String? _error;
  int _currentPreviewPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.materialId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMaterial());
    } else if (widget.product != null) {
      _buildMaterialFromProduct();
    }
  }

  Future<void> _fetchMaterial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<MaterialsProvider>();
      await provider.fetchMaterial(widget.materialId!);
      final fetched = provider.selectedMaterial;
      if (fetched != null) {
        setState(() {
          _material = fetched;
          _isLoading = false;
        });
        if (mounted) {
          context.read<RecentlyViewedProvider>().addToRecentlyViewed(fetched, widget.category);
        }
      } else {
        // Fallback to product map if fetch returned null
        _buildMaterialFromProduct();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Fallback to product map on error
      _buildMaterialFromProduct();
      setState(() {
        _isLoading = false;
        if (_material == null) {
          _error = 'Failed to load material details';
        }
      });
    }
  }

  void _buildMaterialFromProduct() {
    if (widget.product == null) return;
    final p = widget.product!;
    var priceValue = p['price'];
    double parsedPrice = 0;
    if (priceValue is double) {
      parsedPrice = priceValue;
    } else if (priceValue is int) {
      parsedPrice = priceValue.toDouble();
    } else if (priceValue != null) {
      parsedPrice = double.tryParse(
            priceValue.toString().replaceAll('LKR ', '').replaceAll(',', ''),
          ) ??
          0;
    }

    _material = StudyMaterial(
      id: p['id'] ?? 0,
      userId: 0,
      moduleId: 0,
      title: p['title'] ?? 'Study Material',
      description: p['description'] as String?,
      price: parsedPrice,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String get _title => _material?.title ?? widget.product?['title'] ?? 'Study Material';

  double get _price {
    if (_material != null) return _material!.price;
    if (widget.product?['price'] != null) {
      var priceValue = widget.product!['price'];
      if (priceValue is double) return priceValue;
      if (priceValue is int) return priceValue.toDouble();
      return double.tryParse(
            priceValue.toString().replaceAll('LKR ', '').replaceAll(',', ''),
          ) ??
          0;
    }
    return 0;
  }

  String get _description =>
      _material?.description ?? widget.product?['description'] ?? 'Study material with detailed explanations and practical examples.';

  String get _moduleName =>
      _material?.module?.name ?? widget.product?['module'] ?? _title.split(' ').take(3).join(' ');

  String get _level => widget.product?['level'] ?? 'Level 5';

  String get _school {
    // Derive from module's level chain if available, otherwise from category
    final category = widget.category ?? 'Computing';
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

  String get _sellerName => _material?.seller?.name ?? 'Unknown Seller';

  String get _sellerMemberYear =>
      _material?.seller?.createdAt.year.toString() ?? DateTime.now().year.toString();

  List<String> get _previewImageUrls {
    final images = _material?.previewImages ?? [];
    if (images.isEmpty) return [];
    final storageBase = ApiService.baseUrl.replaceAll('/api', '');
    return images.map((path) {
      if (path.startsWith('http')) return path;
      return '$storageBase${path.startsWith('/') ? path : '/$path'}';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Note Details'), centerTitle: true),
        body: const Center(
          child: CircularProgressIndicator(color: kBrandGreen),
        ),
      );
    }

    if (_error != null && _material == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Note Details'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMaterial,
                style: ElevatedButton.styleFrom(backgroundColor: kBrandGreen),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final fee = _price * 0.05;
    final total = _price + fee;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text('Note Details'), centerTitle: true),
      bottomNavigationBar: !isLandscape ? buildBottomBar(total) : null,
      body: isLandscape
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      buildTitleAndPrice(),
                      const SizedBox(height: 16),
                      buildPreviewCard(),
                      const SizedBox(height: 16),
                      buildDescriptionCard(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      buildModuleCard(),
                      const SizedBox(height: 16),
                      buildSellerCard(),
                      const SizedBox(height: 16),
                      buildPurchaseCard(total, fee),
                      const SizedBox(height: 16),
                      buildBottomBar(total),
                    ],
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildTitleAndPrice(),
                const SizedBox(height: 16),
                buildPreviewCard(),
                const SizedBox(height: 16),
                buildDescriptionCard(),
                const SizedBox(height: 16),
                buildModuleCard(),
                const SizedBox(height: 16),
                buildSellerCard(),
                const SizedBox(height: 16),
                buildPurchaseCard(total, fee),
                const SizedBox(height: 120),
              ],
            ),
    );
  }

  Widget buildTitleAndPrice() {
    final id = _material?.id ?? widget.product?['id'] ?? 0;

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'material-icon-$id',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kBrandGreen.withValues(alpha: 0.8),
                      kBrandGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.book, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Hero(
                tag: 'material-title-$id',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    _title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
            Hero(
              tag: 'material-price-$id',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LKR ${_price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                      fontWeight: FontWeight.bold,
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

  Widget buildPreviewCard() {
    final imageUrls = _previewImageUrls;

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Preview',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (imageUrls.length > 1) ...[
                  const Spacer(),
                  Text(
                    '${_currentPreviewPage + 1} / ${imageUrls.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: imageUrls.isEmpty
                    ? _buildPreviewPlaceholder()
                    : imageUrls.length == 1
                        ? _buildPreviewImage(imageUrls.first)
                        : PageView.builder(
                            itemCount: imageUrls.length,
                            onPageChanged: (index) {
                              setState(() => _currentPreviewPage = index);
                            },
                            itemBuilder: (context, index) {
                              return _buildPreviewImage(imageUrls[index]);
                            },
                          ),
              ),
            ),
            if (imageUrls.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPreviewPage
                          ? kBrandGreen
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Theme.of(context).cardColor,
          child: const Center(
            child: CircularProgressIndicator(
              color: kBrandGreen,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Failed to load preview image: $imageUrl — $error');
        return _buildPreviewPlaceholder();
      },
    );
  }

  Widget _buildPreviewPlaceholder() {
    return Container(
      color: Theme.of(context).cardColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 40,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "Preview not available",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.5),
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
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _descExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                _description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              secondChild: Text(
                _description,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _moduleInfoRow(Icons.menu_book_rounded, 'Module', _moduleName),
            _moduleInfoRow(Icons.school_rounded, 'Level', _level),
            _moduleInfoRow(Icons.apartment_rounded, 'School', _school),
          ],
        ),
      ),
    );
  }

  Widget _moduleInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kBrandGreen, size: 24),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          backgroundColor: kBrandGreen.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: kBrandGreen),
        ),
        title: Text(
          _sellerName,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Verified \u2022 Member since $_sellerMemberYear',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget buildPurchaseCard(double total, double fee) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Purchase Details',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _priceRow('Material Price', _price),
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
    final materialId = _material?.id ?? widget.product?['id'] ?? 0;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLandscape)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'LKR ${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Row(
              children: [
                if (!isLandscape)
                  Expanded(
                    child: Text(
                      'LKR ${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(
                  flex: isLandscape ? 1 : 0,
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Purchase feature coming soon!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: kBrandGreen,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: kBrandGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Purchase Now'),
                  ),
                ),
                const SizedBox(width: 8),
                // Selector rebuilds only when isInCart changes, not on every cart update
                Selector<CartProvider, bool>(
                  selector: (_, cart) => materialId > 0 && cart.isInCart(materialId),
                  builder: (context, isInCart, child) {
                    return OutlinedButton.icon(
                      onPressed: isInCart ? null : _addToCart,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isInCart ? Colors.grey : kBrandGreen,
                        side: BorderSide(color: isInCart ? Colors.grey : kBrandGreen),
                      ),
                      icon: Icon(isInCart ? Icons.check : Icons.add_shopping_cart),
                      label: Text(isInCart ? 'In Cart' : 'Cart'),
                    );
                  },
                ),
              ],
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
    final material = _material ??
        StudyMaterial(
          id: widget.product?['id'] ?? 0,
          userId: 0,
          moduleId: 0,
          title: _title,
          description: _description,
          price: _price,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    context.read<CartProvider>().addItem(material);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Added to cart successfully!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kBrandGreen,
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
