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
    ref
        .read(serviceBookingRepositoryProvider)
        .streamBookingStatus(widget.bookingId)
        .listen(
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error loading job: $e')));
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
      await ref
          .read(serviceBookingRepositoryProvider)
          .updateServiceStatus(widget.bookingId, newStatus);
      if (mounted) Navigator.pop(context); // close loader
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  void _openMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not open maps')));
      }
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
    final method = b.details['method'] ?? 'Cash';
    final isCashPending = method == 'Cash' && b.status != 'paid' && b.status != 'completed';

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
            if (isCashPending) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CASH COLLECTION PENDING',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please collect ₹${b.totalCost} at the counter.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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
            if (isCashPending) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.monetization_on_rounded),
                  label: const Text('Collect Cash & Mark Paid', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    unawaited(showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    ));
                    try {
                      await ref.read(serviceBookingRepositoryProvider).collectCashPayment(b.id);
                      if (mounted) {
                        navigator.pop(); // close loader
                        messenger.showSnackBar(const SnackBar(
                          content: Text('Payment successfully collected and marked paid!'),
                          backgroundColor: Colors.green,
                        ));
                      }
                    } catch (e) {
                      if (mounted) {
                        navigator.pop(); // close loader
                        messenger.showSnackBar(SnackBar(
                          content: Text('Failed to collect cash: $e'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  },
                ),
              ),
            ],
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
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    if (status == 'refunded') {
      return const Center(
        child: Text('Job Cancelled & Refunded',
            style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      );
    }

    if (status == 'pending' || status == 'assigned') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus('on_my_way'),
              child: const Text('Mark as On My Way'),
            ),
          ),
          const SizedBox(height: 8),
          _buildRefundButton(),
        ],
      );
    } else if (status == 'on_my_way') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus('arrived'),
              child: const Text('Mark as Arrived'),
            ),
          ),
          const SizedBox(height: 8),
          _buildRefundButton(),
        ],
      );
    } else if (status == 'arrived' || status == 'in_progress') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus('completed'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Complete Job'),
            ),
          ),
          const SizedBox(height: 8),
          _buildRefundButton(),
        ],
      );
    } else if (status == 'completed') {
      return const Center(
        child: Text('Job Completed',
            style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRefundButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.cancel_presentation_rounded),
        label: const Text('No Show / Cancel (Refund)', style: TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _confirmRefund(),
      ),
    );
  }

  void _confirmRefund() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Cancel & Refund'),
        content: const Text(
          'Are you sure you want to mark this booking as Cancelled/No-Show? '
          'This will automatically refund the payment amount to the customer\'s account balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext); // close confirm dialog
              
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              unawaited(showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              ));

              try {
                await ref.read(serviceBookingRepositoryProvider).refundBooking(widget.bookingId);
                if (mounted) {
                  navigator.pop(); // close loader
                  messenger.showSnackBar(const SnackBar(
                    content: Text('Booking cancelled and refund processed successfully!'),
                    backgroundColor: Colors.green,
                  ));
                }
              } catch (e) {
                if (mounted) {
                  navigator.pop(); // close loader
                  messenger.showSnackBar(SnackBar(
                    content: Text('Failed to process refund: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
  }
}
