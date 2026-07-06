import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post It')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.push('/receipt-scanner'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Receipt'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/receipt-history'),
              icon: const Icon(Icons.history),
              label: const Text('Receipt History'),
            ),
          ],
        ),
      ),
    );
  }
}
