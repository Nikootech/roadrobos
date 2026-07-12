import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServiceTypeSelectorScreen extends StatelessWidget {
  const ServiceTypeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildServiceCard(
              context,
              title: 'Car Wash',
              icon: Icons.local_car_wash,
              basePrice: 500,
              serviceId: 'car_wash',
            ),
            _buildServiceCard(
              context,
              title: 'EV Charging',
              icon: Icons.electrical_services,
              basePrice: 300,
              serviceId: 'ev_charging',
            ),
            _buildServiceCard(
              context,
              title: 'Repair/Breakdown',
              icon: Icons.build,
              basePrice: 1000,
              serviceId: 'repair',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required double basePrice,
    required String serviceId,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to booking flow
          context.push('/book_service/$serviceId', extra: {
            'title': title,
            'basePrice': basePrice,
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Starting at ₹${basePrice.toInt()}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
