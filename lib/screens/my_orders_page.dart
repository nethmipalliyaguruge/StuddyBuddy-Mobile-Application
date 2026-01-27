import 'package:flutter/material.dart';
import 'package:studybuddy/utils/constants.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildOrderItem(
            orderNumber: '#ORD001',
            noteName: 'Marketing Principles - Key Models',
            price: 'LKR 500.00',
            orderDate: '2024-09-15',
            status: 'Completed',
            downloadAvailable: true,
          ),
          const SizedBox(height: 12),
          buildOrderItem(
            orderNumber: '#ORD002',
            noteName: 'Web Forms & Validation Checklist',
            price: 'LKR 360.00',
            orderDate: '2024-09-20',
            status: 'Completed',
            downloadAvailable: true,
          ),
          const SizedBox(height: 12),
          buildOrderItem(
            orderNumber: '#ORD003',
            noteName: 'Strategic Mgmt - Global Case Deck',
            price: 'LKR 700.00',
            orderDate: '2024-09-25',
            status: 'Completed',
            downloadAvailable: true,
          ),
        ],
      ),
    );
  }

  Widget buildOrderItem({
    required String orderNumber,
    required String noteName,
    required String price,
    required String orderDate,
    required String status,
    required bool downloadAvailable,
  }) {
    return Builder(
      builder: (context) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with order number and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kBrandGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  noteName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kBrandGreen,
                      ),
                    ),
                    Text(
                      'Ordered: $orderDate',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (downloadAvailable)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading $noteName...')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download Notes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
