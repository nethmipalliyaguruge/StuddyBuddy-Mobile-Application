import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studybuddy/providers/auth_provider.dart';
import 'package:studybuddy/providers/theme_provider.dart';
import 'package:studybuddy/providers/notes_provider.dart';
import 'package:studybuddy/providers/purchases_provider.dart';
import 'package:studybuddy/screens/login_page.dart';
import 'package:studybuddy/screens/my_orders_page.dart';
import 'package:studybuddy/screens/personal_details_screen.dart';
import 'package:studybuddy/screens/cart_page.dart';
import 'package:studybuddy/services/battery_service.dart';
import 'package:studybuddy/services/geolocation_service.dart';
import 'package:studybuddy/utils/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final BatteryService _batteryService = BatteryService();
  final GeolocationService _geolocationService = GeolocationService();
  final ImagePicker _imagePicker = ImagePicker();
  BatteryInfo? _batteryInfo;
  LocationInfo? _locationInfo;
  bool _locationLoading = false;
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().fetchNotes();
      context.read<PurchasesProvider>().fetchPurchases();
      _loadBatteryInfo();
      _loadLocation();
    });
  }

  Future<void> _loadBatteryInfo() async {
    try {
      final info = await _batteryService.getBatteryInfo();
      if (mounted) {
        setState(() => _batteryInfo = info);
      }
    } catch (e) {
      // Battery info not available on this platform
    }
  }

  Future<void> _loadLocation() async {
    if (mounted) setState(() => _locationLoading = true);
    try {
      final info = await _geolocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationInfo = info;
          _locationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: kBrandGreen),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: kBrandGreen),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() => _profileImage = image);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated!', style: TextStyle(color: Colors.white)),
            backgroundColor: kBrandGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Tooltip(
              message: 'Shopping cart',
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
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
          ],
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Consumer2<AuthProvider, PurchasesProvider>(
              builder: (context, authProvider, purchasesProvider, child) {
                final user = authProvider.user;
                return Column(
                  children: [
                    // Profile Avatar
                    GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: kBrandGreen.withValues(alpha: 0.1),
                            backgroundImage: _profileImage != null
                                ? (kIsWeb
                                    ? NetworkImage(_profileImage!.path)
                                    : FileImage(File(_profileImage!.path)))
                                    as ImageProvider
                                : null,
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.account_circle,
                                    size: 80,
                                    color: kBrandGreen,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: kBrandGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User Name
                    Text(
                      user?.name ?? "Guest User",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kBrandGreen,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // User Email
                    Text(
                      user?.email ?? "guest@studybuddy.com",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),

                    // Stats Row
                    Consumer<NotesProvider>(
                      builder: (context, notesProvider, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildStatItem(
                              context,
                              "Notes",
                              notesProvider.noteCount.toString(),
                            ),
                            buildStatItem(
                              context,
                              "Orders",
                              purchasesProvider.purchaseCount.toString(),
                            ),
                            buildStatItem(
                              context,
                              "Spent",
                              "LKR ${purchasesProvider.totalSpent.toStringAsFixed(0)}",
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Profile Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                ProfileOption(
                  icon: Icons.person_outline,
                  label: "Personal Details",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const PersonalDetailsScreen(),
                      ),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.credit_card_outlined,
                  label: "My Card",
                  onTap: () {
                    showComingSoonDialog(context, "My Card");
                  },
                ),
                ProfileOption(
                  icon: Icons.shopping_bag_outlined,
                  label: "My Orders",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const MyOrdersPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Dark Mode Toggle
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kBrandGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              key: ValueKey(themeProvider.isDarkMode),
                              color: kBrandGreen,
                              size: 24,
                            ),
                          ),
                        ),
                        title: Text(
                          'Dark Mode',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        trailing: Switch.adaptive(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: kBrandGreen,
                        ),
                      ),
                    );
                  },
                ),

                // Battery Status
                _buildBatteryWidget(),

                // Location
                _buildLocationWidget(),

                ProfileOption(
                  icon: Icons.notifications_outlined,
                  label: "Notifications",
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    showComingSoonDialog(context, "Notifications");
                  },
                ),
                ProfileOption(
                  icon: Icons.language_outlined,
                  label: "Language",
                  subtitle: "English",
                  onTap: () {
                    showComingSoonDialog(context, "Language Settings");
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Support',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                ProfileOption(
                  icon: Icons.help_outline,
                  label: "Help Center",
                  onTap: () {
                    showComingSoonDialog(context, "Help Center");
                  },
                ),
                ProfileOption(
                  icon: Icons.privacy_tip_outlined,
                  label: "Privacy Policy",
                  onTap: () {
                    showComingSoonDialog(context, "Privacy Policy");
                  },
                ),
                ProfileOption(
                  icon: Icons.article_outlined,
                  label: "Terms and Conditions",
                  onTap: () {
                    showComingSoonDialog(context, "Terms and Conditions");
                  },
                ),

                const SizedBox(height: 24),

                // Logout Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showLogoutDialog(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // LEFT SIDE - Profile Header Section
        Expanded(
          flex: 2,
          child: SingleChildScrollView(child: _buildProfileHeader()),
        ),

        // RIGHT SIDE - Profile Options
        Expanded(
          flex: 3,
          child: SingleChildScrollView(child: _buildProfileOptions()),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Consumer2<AuthProvider, PurchasesProvider>(
        builder: (context, authProvider, purchasesProvider, child) {
          final user = authProvider.user;
          return Column(
            children: [
              // Profile Avatar
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: kBrandGreen.withValues(alpha: 0.1),
                      backgroundImage: _profileImage != null
                          ? (kIsWeb
                              ? NetworkImage(_profileImage!.path)
                              : FileImage(File(_profileImage!.path)))
                              as ImageProvider
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.account_circle,
                              size: 100,
                              color: kBrandGreen,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: kBrandGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // User Name
              Text(
                user?.name ?? "Guest User",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kBrandGreen,
                ),
              ),
              const SizedBox(height: 8),

              // User Email
              Text(
                user?.email ?? "guest@studybuddy.com",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // Stats in landscape - vertical layout
              Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  return Column(
                    children: [
                      _buildLandscapeStatItem(
                        context,
                        "Notes",
                        notesProvider.noteCount.toString(),
                      ),
                      const SizedBox(height: 16),
                      _buildLandscapeStatItem(
                        context,
                        "Orders",
                        purchasesProvider.purchaseCount.toString(),
                      ),
                      const SizedBox(height: 16),
                      _buildLandscapeStatItem(
                        context,
                        "Spent",
                        "LKR ${purchasesProvider.totalSpent.toStringAsFixed(0)}",
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLandscapeStatItem(
    BuildContext context,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: kBrandGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: kBrandGreen,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: kBrandGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          ProfileOption(
            icon: Icons.person_outline,
            label: "Personal Details",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const PersonalDetailsScreen(),
                ),
              );
            },
          ),
          ProfileOption(
            icon: Icons.credit_card_outlined,
            label: "My Card",
            onTap: () {
              showComingSoonDialog(context, "My Card");
            },
          ),
          ProfileOption(
            icon: Icons.shopping_bag_outlined,
            label: "My Orders",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const MyOrdersPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Dark Mode Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kBrandGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        key: ValueKey(themeProvider.isDarkMode),
                        color: kBrandGreen,
                        size: 24,
                      ),
                    ),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  trailing: Switch.adaptive(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: kBrandGreen,
                  ),
                ),
              );
            },
          ),

          // Battery Status
          _buildBatteryWidget(),

          // Location
          _buildLocationWidget(),

          ProfileOption(
            icon: Icons.notifications_outlined,
            label: "Notifications",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              showComingSoonDialog(context, "Notifications");
            },
          ),
          ProfileOption(
            icon: Icons.language_outlined,
            label: "Language",
            subtitle: "English",
            onTap: () {
              showComingSoonDialog(context, "Language Settings");
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Support',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          ProfileOption(
            icon: Icons.help_outline,
            label: "Help Center",
            onTap: () {
              showComingSoonDialog(context, "Help Center");
            },
          ),
          ProfileOption(
            icon: Icons.privacy_tip_outlined,
            label: "Privacy Policy",
            onTap: () {
              showComingSoonDialog(context, "Privacy Policy");
            },
          ),
          ProfileOption(
            icon: Icons.article_outlined,
            label: "Terms and Conditions",
            onTap: () {
              showComingSoonDialog(context, "Terms and Conditions");
            },
          ),

          const SizedBox(height: 24),

          // Logout Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 32),
            child: ElevatedButton.icon(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryWidget() {
    if (_batteryInfo == null) return const SizedBox.shrink();

    final level = _batteryInfo!.level;
    final isCharging = _batteryInfo!.isCharging;
    final isLow = _batteryInfo!.isLow;

    IconData batteryIcon;
    Color batteryColor;
    if (isCharging) {
      batteryIcon = Icons.battery_charging_full;
      batteryColor = kBrandGreen;
    } else if (level > 80) {
      batteryIcon = Icons.battery_full;
      batteryColor = kBrandGreen;
    } else if (level > 50) {
      batteryIcon = Icons.battery_5_bar;
      batteryColor = Colors.green;
    } else if (level > 20) {
      batteryIcon = Icons.battery_3_bar;
      batteryColor = Colors.orange;
    } else {
      batteryIcon = Icons.battery_1_bar;
      batteryColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: batteryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(batteryIcon, color: batteryColor, size: 24),
        ),
        title: Text(
          'Battery',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${_batteryInfo!.stateString}${isLow ? ' - Low battery!' : ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isLow ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          '$level%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: batteryColor,
          ),
        ),
        onTap: _loadBatteryInfo,
      ),
    );
  }

  Widget _buildLocationWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _locationLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                )
              : const Icon(Icons.location_on, color: Colors.blue, size: 24),
        ),
        title: Text(
          'Location',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _locationInfo != null
              ? _locationInfo!.city
              : (_locationLoading ? 'Detecting location...' : 'Tap to detect location'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: _locationInfo != null
            ? Text(
                _locationInfo!.coordinatesString,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              )
            : Icon(Icons.my_location, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onTap: _loadLocation,
      ),
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  void showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: Text('$feature feature is coming soon!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context.read<AuthProvider>().logout();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Loginpage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBrandGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kBrandGreen, size: 24),
        ),
        title: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              )
            : null,
        trailing:
            trailing ??
            Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
