import 'package:flutter/material.dart';
import 'package:studybuddy/screens/MyOrdersPage.dart';
import 'package:studybuddy/screens/PersonalDetailsScreen.dart';

const kBrandGreen = Color(0xFF006644);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 32, bottom: 16),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: kBrandGreen.withOpacity(0.1),
                  child: Icon(Icons.account_circle, size: 80, color: kBrandGreen),
                ),
              ),
              Text(
                "John Doe",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kBrandGreen,
                ),
              ),
              const SizedBox(height: 24),
              ProfileOption(
                icon: Icons.person,
                label: "Personal Details",
                onTap: () {
                  Navigator.of(context).push(
                   MaterialPageRoute<void>(
                      builder: (context) => PersonalDetailsScreen(),
                    ),
                  );
                },
              ),
              ProfileOption(
                icon: Icons.credit_card,
                label: "My Card",
                onTap: () {},
              ),
              ProfileOption(
                icon: Icons.shopping_bag,
                label: "My Orders",
                onTap: () {
                  Navigator.of(context).push(
                   MaterialPageRoute<void>(
                      builder: (context) => MyOrdersPage(),
                    ),
                  );
                },
              ),
              ProfileOption(
                icon: Icons.settings,
                label: "Settings",
                onTap: () {},
              ),
              ProfileOption(
                icon: Icons.privacy_tip,
                label: "Privacy Policy",
                onTap: () {},
              ),
              ProfileOption(
                icon: Icons.article,
                label: "Terms and Conditions",
                onTap: () {},
              ),
            ],
          ),
        ),
      );
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileOption({super.key, 
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: kBrandGreen),
                  const SizedBox(width: 14),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: kBrandGreen),
            ],
          ),
        ),
      );
}