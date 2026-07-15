import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../../providers/taxi_provider.dart';
import '../../features/delivery/delivery_providers.dart';
import '../../core/services/osm_maps_service.dart';
import '../../shared/widgets/live_map_widget.dart';

class LocationSearchScreen extends ConsumerStatefulWidget {
  final bool focusPickup;
  final bool isDelivery;
  const LocationSearchScreen({
    super.key,
    this.focusPickup = false,
    this.isDelivery = false,
  });

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  late TextEditingController _pickupController;
  late TextEditingController _dropoffController;
  late FocusNode _pickupFocusNode;
  late FocusNode _dropoffFocusNode;

  final _osmService = OSMMapsService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Add some mock recent locations to match image 4
  final List<Map<String, dynamic>> _recentLocations = [
    {
      'name': 'Kempegowda International Airport',
      'address': 'KIAL Rd, Devanahalli, Bengaluru',
      'lat': 13.1989,
      'lng': 77.7068,
      'type': 'recent'
    },
    {
      'name': 'SMVT Bengaluru Station',
      'address': 'Sir M Visvesvaraya Terminal, Byappanahalli',
      'lat': 12.9880,
      'lng': 77.6525,
      'type': 'recent'
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isDelivery) {
      final deliveryState = ref.read(deliveryOrderProvider);
      _pickupController =
          TextEditingController(text: deliveryState.pickupAddress);
      _dropoffController =
          TextEditingController(text: deliveryState.dropoffAddress);
    } else {
      final taxiState = ref.read(taxiProvider);
      _pickupController =
          TextEditingController(text: taxiState.pickupAddress ?? '');
      _dropoffController =
          TextEditingController(text: taxiState.dropoffAddress ?? '');

      // Auto-fetch location if empty
      if (taxiState.pickupLocation == null) {
        Future.microtask(
            () => ref.read(taxiProvider.notifier).initializeLocation());
      }
    }

    _pickupFocusNode = FocusNode();
    _dropoffFocusNode = FocusNode();

    _pickupController.addListener(_onSearchChanged);
    _dropoffController.addListener(_onSearchChanged);

    _pickupFocusNode.addListener(() => setState(() {}));
    _dropoffFocusNode.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focusPickup) {
        _pickupFocusNode.requestFocus();
      } else {
        _dropoffFocusNode.requestFocus();
      }
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    final query = _pickupFocusNode.hasFocus
        ? _pickupController.text
        : _dropoffController.text;
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    LatLng? biasLoc;
    if (widget.isDelivery) {
      final deliveryState = ref.read(deliveryOrderProvider);
      if (deliveryState.pickupLocation != null) {
        biasLoc = deliveryState.pickupLocation;
      }
    } else {
      final taxiState = ref.read(taxiProvider);
      if (taxiState.pickupLocation != null) {
        biasLoc = taxiState.pickupLocation;
      }
    }

    if (query.length == 2) {
      _osmService.searchAddress(query, biasLocation: biasLoc).then((results) {
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      final results =
          await _osmService.searchAddress(query, biasLocation: biasLoc);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocusNode.dispose();
    _dropoffFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to taxi state changes so current location text updates when fetched
    if (!widget.isDelivery) {
      final taxiState = ref.watch(taxiProvider);
      if (!_pickupFocusNode.hasFocus &&
          taxiState.pickupAddress != null &&
          taxiState.pickupAddress != _pickupController.text) {
        _pickupController.text = taxiState.pickupAddress!;
      }
    }

    final displayList =
        _searchResults.isNotEmpty ? _searchResults : _recentLocations;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Live Map Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: const LiveMapWidget(
              height: 400,
              showLiveIndicator: false,
            ),
          ),

          // 2. Back Button (Top Left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          // 3. Search Bottom Sheet Area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Search Card "Where to?" style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.green.shade600, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black87),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAddressInput(
                                  controller: _pickupController,
                                  focusNode: _pickupFocusNode,
                                  hint: 'Current Location',
                                  isPickup: true,
                                ),
                                const Divider(height: 16),
                                _buildAddressInput(
                                  controller: _dropoffController,
                                  focusNode: _dropoffFocusNode,
                                  hint: 'Where to?',
                                  isPickup: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Searching indicator
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Searching...',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54)),
                        ],
                      ),
                    ),

                  // Suggestions / Recent List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 56),
                      itemBuilder: (context, index) {
                        return _buildLocationItem(displayList[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInput(
      {required TextEditingController controller,
      required FocusNode focusNode,
      required String hint,
      required bool isPickup}) {
    final bool isFocused = focusNode.hasFocus;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(
          fontSize: isFocused ? 18 : 16,
          fontWeight: isFocused ? FontWeight.w800 : FontWeight.w600,
          color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Colors.black38, fontSize: 18, fontWeight: FontWeight.bold),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> loc) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _onLocationSelected(loc);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_outlined,
                    color: Colors.black87, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(loc['address'] ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  void _onLocationSelected(Map<String, dynamic> loc) {
    final latLng = LatLng(loc['lat'], loc['lng']);
    final name = loc['name'];
    final address = loc['address'] as String;

    if (widget.isDelivery) {
      if (_pickupFocusNode.hasFocus) {
        _pickupController.text = address;
        ref.read(deliveryOrderProvider.notifier).setPickup(latLng, address);
        _dropoffFocusNode.requestFocus();
      } else {
        _dropoffController.text = address;
        ref.read(deliveryOrderProvider.notifier).setDropoff(latLng, address);
        context.pop();
      }
    } else {
      if (_pickupFocusNode.hasFocus) {
        _pickupController.text = name;
        ref.read(taxiProvider.notifier).setPickup(latLng, name);
        _dropoffFocusNode.requestFocus();
      } else {
        // Ensure pickup location is set
        final currentState = ref.read(taxiProvider);
        if (currentState.pickupLocation == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait — fetching your current location...'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        _dropoffController.text = name;
        ref.read(taxiProvider.notifier).setDropoff(latLng, name);
        context.pop();
        context.push('/taxi/ride-options');
      }
    }
  }

}
