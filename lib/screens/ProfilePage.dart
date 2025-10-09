import 'package:flutter/material.dart';
import 'package:studybuddy/screens/LoginPage.dart';
import 'package:studybuddy/screens/MyOrdersPage.dart';
import 'package:studybuddy/screens/PersonalDetailsScreen.dart';
import 'package:studybuddy/screens/CartPage.dart';
import '../main.dart';

const kBrandGreen = Color(0xFF006644);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ThemeManager themeManager = ThemeManager();

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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kBrandGreen,
                minimumSize: const Size(60, 40),
                padding: const EdgeInsets.all(8),
              ),
              child: Icon(Icons.shopping_cart),
            ),
          ],
        ),
        backgroundColor: kBrandGreen,
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
            child: Column(
              children: [
                // Profile Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: kBrandGreen.withOpacity(0.1),
                      child: const Icon(
                        Icons.account_circle,
                        size: 80,
                        color: kBrandGreen,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
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
                const SizedBox(height: 16),

                // User Name
                Text(
                  "John Doe",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kBrandGreen,
                  ),
                ),
                const SizedBox(height: 4),

                // User Email
                Text(
                  "john@studybuddy.com",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildStatItem(context, "Notes", "12"),
                    buildStatItem(context, "Orders", "5"),
                    buildStatItem(context, "Spent", "LKR 4,250"),
                  ],
                ),
              ],
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
                    color: Colors.grey[600],
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
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),

                // Dark Mode Toggle
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                        color: kBrandGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          themeManager.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          key: ValueKey(themeManager.isDarkMode),
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
                      themeManager.isDarkMode ? 'Enabled' : 'Disabled',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    trailing: Switch.adaptive(
                      value: themeManager.isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          themeManager.toggleTheme();
                        });
                      },
                      activeColor: kBrandGreen,
                    ),
                  ),
                ),

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
                    color: Colors.grey[600],
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
                      backgroundColor: Colors.red.shade50,
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
      child: Column(
        children: [
          // Profile Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: kBrandGreen.withOpacity(0.1),
                child: const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: kBrandGreen,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: kBrandGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Name
          Text(
            "John Doe",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: kBrandGreen,
            ),
          ),
          const SizedBox(height: 8),

          // User Email
          Text(
            "john@studybuddy.com",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Stats in landscape - vertical layout
          Column(
            children: [
              _buildLandscapeStatItem(context, "Notes", "12"),
              const SizedBox(height: 16),
              _buildLandscapeStatItem(context, "Orders", "5"),
              const SizedBox(height: 16),
              _buildLandscapeStatItem(context, "Spent", "LKR 4,250"),
            ],
          ),
        ],
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
        color: kBrandGreen.withOpacity(0.1),
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
              color: Colors.grey[600],
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
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Dark Mode Toggle
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  color: kBrandGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    themeManager.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    key: ValueKey(themeManager.isDarkMode),
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
                themeManager.isDarkMode ? 'Enabled' : 'Disabled',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              trailing: Switch.adaptive(
                value: themeManager.isDarkMode,
                onChanged: (value) {
                  setState(() {
                    themeManager.toggleTheme();
                  });
                },
                activeColor: kBrandGreen,
              ),
            ),
          ),

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
              color: Colors.grey[600],
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
                backgroundColor: Colors.red.shade50,
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
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  void showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$feature'),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Loginpage()),
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
            color: Colors.black.withOpacity(0.05),
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
            color: kBrandGreen.withOpacity(0.1),
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
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              )
            : null,
        trailing:
            trailing ??
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
