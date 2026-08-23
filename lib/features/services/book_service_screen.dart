import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/service_booking.dart';
import '../../core/repositories/user_vehicle_repository.dart';
import '../../core/repositories/service_booking_repository.dart';
import '../../features/wallet/wallet_providers.dart';
import '../../features/wallet/widgets/insufficient_balance_sheet.dart';
import '../../features/profile/user_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../core/services/unified_sync_service.dart';
import 'service_booking_confirmation_screen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class BookServiceScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String title;
  final double basePrice;

  const BookServiceScreen({
    super.key,
    required this.serviceId,
    required this.title,
    required this.basePrice,
  });

  @override
  ConsumerState<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends ConsumerState<BookServiceScreen> {
  int _currentStep = 0;

  // Step 1
  List<UserVehicle> _vehicles = [];
  UserVehicle? _selectedVehicle;
  bool _isLoadingVehicles = true;

  // Step 2
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;

  // Step 3
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _loadAvailableSlots();
  }

  Future<void> _loadVehicles() async {
    final user = ref.read(userProvider).user;
    if (user == null) return;
    try {
      final vehicles = await ref
          .read(userVehicleRepositoryProvider)
          .getUserVehicles(user.id);
      setState(() {
        _vehicles = vehicles;
        if (vehicles.isNotEmpty) {
          _selectedVehicle = vehicles.firstWhere((v) => v.isPrimary,
              orElse: () => vehicles.first);
        }
        _isLoadingVehicles = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVehicles = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading vehicles: $e')));
      }
    }
  }

  Future<void> _loadAvailableSlots() async {
    setState(() => _isLoadingSlots = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final bookings = await ref
          .read(serviceBookingRepositoryProvider)
          .getBookingsForDate(dateStr);
      final takenSlots = bookings.map((b) => b.time).toSet();

      final allSlots = List.generate(9, (index) => '${9 + index}:00');
      setState(() {
        _availableSlots =
            allSlots.where((s) => !takenSlots.contains(s)).toList();
        if (_availableSlots.isNotEmpty) {
          _selectedTimeSlot = _availableSlots.first;
        } else {
          _selectedTimeSlot = null;
        }
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() => _isLoadingSlots = false);
    }
  }

  void _confirmBooking() async {
    final wallet = ref.read(walletProvider).value;
    final balance = wallet?.balance ?? 0.0;

    if (balance < widget.basePrice) {
      unawaited(showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => InsufficientBalanceSheet(
          requiredAmount: widget.basePrice,
          currentBalance: balance,
        ),
      ));
      return;
    }

    final user = ref.read(userProvider).user;
    if (user == null) return;

    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    ));

    try {
      final booking = ServiceBooking(
        id: const Uuid().v4(), // generate an ID for offline queueing
        customerId: user.id,
        vehicleName: '${_selectedVehicle!.make} ${_selectedVehicle!.model}',
        vehiclePlate: _selectedVehicle!.plateNumber,
        packageName: widget.title,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        time: _selectedTimeSlot!,
        totalCost: widget.basePrice,
        address: _addressController.text,
        details: {'serviceId': widget.serviceId},
        createdAt: DateTime.now(),
      );

      final isOffline = ref.read(connectivityProvider).value ?? false;

      if (isOffline) {
        await ref.read(unifiedSyncServiceProvider).enqueue(
              entityType: 'service_booking',
              action: 'create_service_booking',
              payload: booking.toMap(),
            );
        if (mounted) {
          Navigator.pop(context); // close loader
          _navigateToConfirmation(booking);
        }
      } else {
        await ref
            .read(serviceBookingRepositoryProvider)
            .createServiceBooking(booking);
        if (mounted) {
          Navigator.pop(context); // close loader
          _navigateToConfirmation(booking);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _navigateToConfirmation(ServiceBooking booking) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceBookingConfirmationScreen(
          bookingId: booking.id,
          serviceName: booking.packageName,
          vehicleName: booking.vehicleName,
          vehiclePlate: booking.vehiclePlate,
          date: booking.date,
          time: booking.time,
          address: booking.address ?? '',
          totalCost: booking.totalCost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.title}')),
      body: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0 && _selectedVehicle == null) return;
                if (_currentStep == 1 && _selectedTimeSlot == null) return;
                if (_currentStep == 2 && _addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter an address')));
                  return;
                }
                if (_currentStep == 3) {
                  _confirmBooking();
                  return;
                }
                setState(() => _currentStep += 1);
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                } else {
                  context.pop();
                }
              },
              steps: [
                Step(
                  title: const Text('Select Vehicle'),
                  isActive: _currentStep >= 0,
                  content: _isLoadingVehicles
                      ? const CircularProgressIndicator()
                      : _vehicles.isEmpty
                          ? const Text(
                              'No vehicles found. Please add a vehicle first.')
                          : DropdownButton<UserVehicle>(
                              value: _selectedVehicle,
                              isExpanded: true,
                              items: _vehicles
                                  .map((v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(
                                            '${v.make} ${v.model} (${v.plateNumber})'),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedVehicle = v),
                            ),
                ),
                Step(
                  title: const Text('Select Date & Time'),
                  isActive: _currentStep >= 1,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                          TextButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 30)),
                              );
                              if (d != null) {
                                setState(() {
                                  _selectedDate = d;
                                  _selectedTimeSlot = null;
                                });
                                unawaited(_loadAvailableSlots());
                              }
                            },
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                      if (_isLoadingSlots)
                        const CircularProgressIndicator()
                      else if (_availableSlots.isEmpty)
                        const Text('No slots available for this date.')
                      else
                        Wrap(
                          spacing: 8,
                          children: _availableSlots
                              .map((s) => ChoiceChip(
                                    label: Text(s),
                                    selected: _selectedTimeSlot == s,
                                    onSelected: (sel) => setState(() =>
                                        _selectedTimeSlot = sel ? s : null),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Service Address'),
                  isActive: _currentStep >= 2,
                  content: TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Full Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                Step(
                  title: const Text('Review & Confirm'),
                  isActive: _currentStep >= 3,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service: ${widget.title}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (_selectedVehicle != null)
                        Text(
                            'Vehicle: ${_selectedVehicle!.make} ${_selectedVehicle!.model}'),
                      Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                      if (_selectedTimeSlot != null)
                        Text('Time: $_selectedTimeSlot'),
                      Text('Address: ${_addressController.text}'),
                      const Divider(),
                      Text('Total Cost: ₹${widget.basePrice.toInt()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
