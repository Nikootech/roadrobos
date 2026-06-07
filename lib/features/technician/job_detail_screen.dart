import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/service_booking.dart';
import '../../core/repositories/service_booking_repository.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const JobDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  ServiceBooking? _booking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  void _loadBooking() {
    ref.read(serviceBookingRepositoryProvider).streamBookingStatus(widget.bookingId).listen(
      (booking) {
        if (mounted) {
          setState(() {
            _booking = booking;
            _isLoading = false;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading job: $e')));
        }
      },
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    ));
    try {
      await ref.read(serviceBookingRepositoryProvider).updateServiceStatus(widget.bookingId, newStatus);
      if (mounted) Navigator.pop(context); // close loader
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  void _openMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_booking == null) {
      return const Scaffold(body: Center(child: Text('Job not found')));
    }

    final b = _booking!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              context.push('/chat', extra: {
                'bookingId': b.id,
                'receiverId': b.customerId,
                'receiverName': 'Customer',
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard('Service Details', [
              _buildRow('Package', b.packageName),
              _buildRow('Date', b.date),
              _buildRow('Time', b.time),
              _buildRow('Status', b.status.toUpperCase(), isHighlight: true),
            ]),
            const SizedBox(height: 16),
            _buildCard('Vehicle Info', [
              _buildRow('Model', b.vehicleName),
              _buildRow('Plate', b.vehiclePlate),
            ]),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(b.address ?? 'No address provided'),
                    const SizedBox(height: 12),
                    if (b.address != null && b.address!.isNotEmpty)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: const Text('Get Directions'),
                        onPressed: () => _openMaps(b.address!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(b.status),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    if (status == 'pending' || status == 'assigned') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus('on_my_way'),
          child: const Text('Mark as On My Way'),
        ),
      );
    } else if (status == 'on_my_way') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus('arrived'),
          child: const Text('Mark as Arrived'),
        ),
      );
    } else if (status == 'arrived' || status == 'in_progress') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus('completed'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text('Complete Job'),
        ),
      );
    } else if (status == 'completed') {
      return const Center(
        child: Text('Job Completed', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }
}
