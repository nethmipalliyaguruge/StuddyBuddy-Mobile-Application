import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/providers/auth_provider.dart';
import 'package:studybuddy/providers/cart_provider.dart';
import 'package:studybuddy/providers/materials_provider.dart';
import 'package:studybuddy/providers/connectivity_provider.dart';
import 'package:studybuddy/providers/theme_provider.dart';
import 'package:studybuddy/providers/notes_provider.dart';
import 'package:studybuddy/providers/purchases_provider.dart';
import 'package:studybuddy/screens/add_note_page.dart';
import 'package:studybuddy/screens/cart_page.dart';
import 'package:studybuddy/screens/detail_page.dart';
import 'package:studybuddy/screens/explore_page.dart';
import 'package:studybuddy/screens/notes_page.dart';
import 'package:studybuddy/screens/profile_page.dart';
import 'package:studybuddy/screens/recently_viewed_page.dart';
import 'package:studybuddy/providers/recently_viewed_provider.dart';
import 'package:studybuddy/services/light_sensor_service.dart';
import 'package:studybuddy/services/shake_service.dart';
import 'package:studybuddy/utils/constants.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _index = 0;
  final LightSensorService _lightSensorService = LightSensorService();
  final ShakeService _shakeService = ShakeService();
  bool _darkModeSuggested = false;

  final _pages = const [HomePage(), ExplorePage(), NotesPage(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _initLightSensor();
    _initShakeDetector();
  }

  @override
  void dispose() {
    _lightSensorService.dispose();
    _shakeService.dispose();
    super.dispose();
  }

  void _initShakeDetector() {
    try {
      _shakeService.startListening(() {
        if (!mounted) return;
        // Refresh all data on shake
        context.read<NotesProvider>().fetchNotes();
        context.read<PurchasesProvider>().fetchPurchases();
        context.read<MaterialsProvider>().fetchMaterials(forceRefresh: true);
        context.read<AuthProvider>().refreshUser();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.vibration, color: Colors.white),
                SizedBox(width: 8),
                Text('Shake detected! Refreshing...', style: TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: kBrandGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    } catch (e) {
      // Accelerometer not available on this platform
    }
  }

  void _initLightSensor() {
    try {
      _lightSensorService.startListening((lux) {
        if (!mounted || _darkModeSuggested) return;

        final themeProvider = context.read<ThemeProvider>();

        // Suggest dark mode if low light and currently in light mode
        if (lux < 50 && !themeProvider.isDarkMode) {
          _darkModeSuggested = true;
          _showDarkModeSuggestion();
        }
      });
    } catch (e) {
      // Light sensor not available on this platform (e.g., web)
    }
  }

  void _showDarkModeSuggestion() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Low light detected. Switch to dark mode?',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey.shade700,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'ENABLE',
          textColor: kBrandGreen,
          onPressed: () {
            context.read<ThemeProvider>().setDarkMode();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, child) {
              if (connectivity.isOnline) return const SizedBox.shrink();
              return MaterialBanner(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.wifi_off, color: Colors.white),
                backgroundColor: Colors.red.shade700,
                content: const Text(
                  'You are offline. Showing cached data.',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => connectivity.checkConnectivity(),
                    child: const Text(
                      'RETRY',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(child: _pages[_index]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int newIndex) {
          setState(() => _index = newIndex); // switch page
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(icon: Icon(Icons.note_rounded), label: 'Notes'),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch data when home page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().fetchNotes();
      context.read<PurchasesProvider>().fetchPurchases();
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
              'StudyBuddy',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWelcomeSection(context),
            const SizedBox(height: 24),
            buildQuickActionsSection(context),
            const SizedBox(height: 24),
            buildMyNotesSection(context),
            const SizedBox(height: 24),
            buildRecentlyViewedSection(context),
            const SizedBox(height: 24),
            buildCategoriesPreview(context),
            const SizedBox(height: 24),
            buildStatsSection(context),
          ],
        ),
      ),
    );
  }

  Widget buildWelcomeSection(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.user?.name ?? 'Student';
        final firstName = userName.split(' ').first;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).cardColor : null,
            gradient: isDark
                ? null
                : LinearGradient(
                    colors: [kBrandGreen, kBrandGreen.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $firstName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to continue your learning journey?',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  return Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: isDark
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${notesProvider.noteCount} notes available',
                        style: TextStyle(
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: buildActionCard(
                context: context,
                icon: Icons.explore,
                title: 'Browse Notes',
                subtitle: 'View detailed notes',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExplorePage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildActionCard(
                context: context,
                icon: Icons.note_add,
                title: 'Add Note',
                subtitle: 'Create new note',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNotePage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return buildActionCard(
                    context: context,
                    icon: Icons.shopping_cart,
                    title: 'My Cart',
                    subtitle: '${cartProvider.itemCount} items',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildActionCard(
                context: context,
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'Manage account',
                color: kBrandGreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildActionCard(
                context: context,
                icon: Icons.history,
                title: 'Recent',
                subtitle: 'Recently viewed',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecentlyViewedPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMyNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Notes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotesPage()),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              if (notesProvider.notes.isEmpty) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildFeaturedNoteCard(
                      context: context,
                      title: 'Digital Technologies Guide',
                      subtitle: 'Digital Technologies',
                      price: 'LKR 3000',
                      rating: 4.8,
                      category: 'Computing',
                    ),
                    buildFeaturedNoteCard(
                      context: context,
                      title: 'Networking Security Notes',
                      subtitle: 'Networking & Cyber Security',
                      price: 'LKR 2800',
                      rating: 4.9,
                      category: 'Computing',
                    ),
                    buildFeaturedNoteCard(
                      context: context,
                      title: 'Mobile App UI Patterns (Slides)',
                      subtitle: 'Mobile App Development',
                      price: 'LKR 5600',
                      rating: 4.7,
                      category: 'Computing',
                    ),
                  ],
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    notesProvider.notes.length > 5
                        ? 5
                        : notesProvider.notes.length,
                itemBuilder: (context, index) {
                  final note = notesProvider.notes[index];
                  return buildFeaturedNoteCard(
                    context: context,
                    title: note.title,
                    subtitle: note.module?.name ?? 'Study Material',
                    price: 'LKR ${note.price.toStringAsFixed(0)}',
                    rating: 4.5 + (index * 0.1),
                    category: 'Computing',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildRecentlyViewedSection(BuildContext context) {
    return Consumer<RecentlyViewedProvider>(
      builder: (context, provider, child) {
        final items = provider.recentlyViewed;

        if (items.isEmpty) return const SizedBox.shrink();

        final displayItems = items.length > 5 ? items.sublist(0, 5) : items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Viewed',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecentlyViewedPage(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final material = displayItems[index];
                  final category = provider.categoryFor(material.id);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailPage(
                            materialId: material.id,
                            product: {
                              'id': material.id,
                              'title': material.title,
                              'description': material.description ?? 'Study material',
                              'price': material.price,
                            },
                            category: category ?? 'Computing',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
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
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.book, color: Colors.white, size: 28),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material.title,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'LKR ${material.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: kBrandGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildFeaturedNoteCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String price,
    required double rating,
    String? category,
  }) {
    return GestureDetector(
      onTap: () {
        // Create note data to pass to detail page
        final noteData = {
          'title': title,
          'subtitle': subtitle,
          'price': price,
          'rating': rating,
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailPage(
              product: noteData,
              category:
                  category ?? 'Computing', // Use passed category or default
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kBrandGreen.withValues(alpha: 0.8), kBrandGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.book, color: Colors.white, size: 32),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kBrandGreen,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoriesPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Browse Categories',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExplorePage()),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: buildCategoryCard(
                context: context,
                icon: Icons.computer,
                title: 'Computing',
                count: '25 notes',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildCategoryCard(
                context: context,
                icon: Icons.business,
                title: 'Business',
                count: '18 notes',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildCategoryCard(
                context: context,
                icon: Icons.gavel,
                title: 'Law',
                count: '12 notes',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCategoryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsSection(BuildContext context) {
    return Consumer<PurchasesProvider>(
      builder: (context, purchasesProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatItem(
                context,
                'Notes Owned',
                purchasesProvider.purchaseCount.toString(),
              ),
              buildStatItem(
                context,
                'Total Spent',
                'LKR ${purchasesProvider.totalSpent.toStringAsFixed(0)}',
              ),
              Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  return buildStatItem(
                    context,
                    'My Notes',
                    notesProvider.noteCount.toString(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: kBrandGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
