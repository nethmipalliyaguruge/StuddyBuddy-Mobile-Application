import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/cart_provider.dart';
import 'package:studybuddy/providers/materials_provider.dart';
import 'package:studybuddy/providers/search_history_provider.dart';
import 'package:studybuddy/models/material.dart';
import 'package:studybuddy/screens/cart_page.dart';
import 'package:studybuddy/screens/detail_page.dart';
import 'package:studybuddy/utils/constants.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  String selectedCategory = 'Computing';

  late AnimationController _shimmerController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchHistory = false;

  // Map category names to school IDs from Laravel backend
  final Map<String, int> categoryToSchoolId = {
    'Computing': 1,
    'Business': 2,
    'Law': 3,
  };

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _searchFocusNode.addListener(() {
      setState(() {
        _showSearchHistory = _searchFocusNode.hasFocus && _searchController.text.isEmpty;
      });
    });
    // Fetch materials filtered by default category (Computing = school_id 1)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMaterialsByCategory();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _fetchMaterialsByCategory() {
    final schoolId = categoryToSchoolId[selectedCategory];
    final provider = context.read<MaterialsProvider>();
    provider.setFilters(schoolId: schoolId, search: _searchController.text.isEmpty ? null : _searchController.text.trim());
    provider.fetchMaterials();
  }

  void _onSearchSubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    context.read<SearchHistoryProvider>().addSearch(trimmed);
    _searchFocusNode.unfocus();
    setState(() => _showSearchHistory = false);
    _fetchMaterialsByCategory();
  }

  void _clearSearch() {
    _searchController.clear();
    final provider = context.read<MaterialsProvider>();
    final schoolId = categoryToSchoolId[selectedCategory];
    provider.setFilters(schoolId: schoolId);
    provider.fetchMaterials();
    setState(() => _showSearchHistory = false);
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
                    Tooltip(
                      message: 'Shopping cart',
                      child: ElevatedButton(
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
          buildSearchBar(),
          buildCategoryTabs(),
          Expanded(
            child: _showSearchHistory
                ? buildSearchHistoryList()
                : buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search materials...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearchSubmitted,
        onChanged: (value) {
          setState(() {
            _showSearchHistory = _searchFocusNode.hasFocus && value.isEmpty;
          });
        },
      ),
    );
  }

  Widget buildSearchHistoryList() {
    return Consumer<SearchHistoryProvider>(
      builder: (context, historyProvider, child) {
        final history = historyProvider.history;

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent searches',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => historyProvider.clearHistory(),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            ...history.map((query) {
              return ListTile(
                leading: const Icon(Icons.history, size: 20),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => historyProvider.removeSearch(query),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () {
                  _searchController.text = query;
                  _onSearchSubmitted(query);
                },
              );
            }),
          ],
        );
      },
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
        // Fetch materials filtered by the selected category's school
        _fetchMaterialsByCategory();
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
    return Consumer<MaterialsProvider>(
      builder: (context, materialsProvider, child) {
        // Show shimmer skeleton while fetching
        if (materialsProvider.isLoading) {
          return _buildShimmerList();
        }

        // Use API data or provider's offline/cache fallback
        List<StudyMaterial> materials = materialsProvider.materials;

        if (materials.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              return _buildMaterialCard(materials[index]);
            },
          );
        }

        // Empty result — offline with no cached data, or truly empty
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                materialsProvider.isOffline
                    ? Icons.cloud_off
                    : Icons.folder_open,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                materialsProvider.isOffline
                    ? 'You\'re offline with no cached data'
                    : 'No materials found for $selectedCategory',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (materialsProvider.isOffline) ...[
                const SizedBox(height: 8),
                Text(
                  'Connect to the internet to browse materials',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildShimmerCard();
          },
        );
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
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
            _shimmerBox(width: 60, height: 60, borderRadius: 10),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 160, height: 14, borderRadius: 4),
                  const SizedBox(height: 8),
                  _shimmerBox(width: double.infinity, height: 12, borderRadius: 4),
                  const SizedBox(height: 6),
                  _shimmerBox(width: 120, height: 12, borderRadius: 4),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _shimmerBox(width: 70, height: 18, borderRadius: 10),
                      const SizedBox(width: 8),
                      _shimmerBox(width: 30, height: 14, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _shimmerBox(width: 80, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                _shimmerBox(width: 60, height: 32, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    required double borderRadius,
    double? width,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + 2.0 * _shimmerController.value, 0),
              end: Alignment(1.0 + 2.0 * _shimmerController.value, 0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialCard(StudyMaterial material) {
    // Convert StudyMaterial to Map for navigation to detail page
    final productMap = {
      'id': material.id,
      'title': material.title,
      'description': material.description ?? 'Study material',
      'price': material.price,
      'rating': 4.5, // Default rating since API may not have it
      'level': material.module?.name ?? 'Level 5',
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NoteDetailPage(
              materialId: material.id,
              product: productMap,
              category: selectedCategory,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
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
              // Icon with Hero animation
              Hero(
                tag: 'material-icon-${material.id}',
                child: Container(
                  width: 60,
                  height: 60,
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
                  child:
                      const Icon(Icons.book, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'material-title-${material.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          material.title,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      material.description ?? 'Study material',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              material.module?.name ?? 'Module',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          '4.5',
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
                  Hero(
                    tag: 'material-price-${material.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        'LKR ${material.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kBrandGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Selector rebuilds only this button when isInCart changes
                  Selector<CartProvider, bool>(
                    selector: (_, cart) => cart.isInCart(material.id),
                    builder: (context, isInCart, child) {
                      return ElevatedButton(
                        onPressed: isInCart
                            ? null
                            : () {
                                _addMaterialToCart(material);
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
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addMaterialToCart(StudyMaterial material) {
    context.read<CartProvider>().addItem(material);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${material.title} added to cart!',
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
