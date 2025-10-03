import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      "School of Computing",
      "School of Business",
      "School of Law",
      "Level 4",
      "Level 5",
      "Level 6",
      "Database Systems",
      "Web Development",
      // add more modules if you want
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse by Categories"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: List.generate(categories.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped: ${categories[index]}')),
                      );
                    },
                    child: Card(
                      color: Colors.green[100 * ((index % 8) + 1)],
                      child: Center(
                        child: Text(
                          categories[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
