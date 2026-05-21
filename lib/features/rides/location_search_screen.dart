import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:go_router/go_router.dart';
import '../../providers/taxi_provider.dart';
import '../../core/services/osm_maps_service.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class LocationSearchScreen extends ConsumerStatefulWidget {
  final bool focusPickup;
  const LocationSearchScreen({super.key, this.focusPickup = false});

  @override
  ConsumerState<LocationSearchScreen> createState() => _LocationSearchScreenState();
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

  @override
  void initState() {
    super.initState();
    final taxiState = ref.read(taxiProvider);
    _pickupController = TextEditingController(text: taxiState.pickupAddress ?? '');
    _dropoffController = TextEditingController(text: taxiState.dropoffAddress ?? '');
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
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _pickupFocusNode.hasFocus ? _pickupController.text : _dropoffController.text;
      
      if (query.length < 3) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);
      final results = await _osmService.searchAddress(query);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text('Select Location', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Input Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, color: Color(0xFF22C55E), size: 10),
                      Container(width: 1.5, height: 40, margin: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(1))),
                      const Icon(Icons.circle, color: Color(0xFFF97316), size: 10),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildAddressInput(controller: _pickupController, focusNode: _pickupFocusNode, hint: 'Pickup Location', isPickup: true),
                        const SizedBox(height: 12),
                        _buildAddressInput(controller: _dropoffController, focusNode: _dropoffFocusNode, hint: 'Drop Location', isPickup: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildActionButton(
                    Iconsax.location, 
                    'Select from map',
                    onTap: () async {
                      final result = await context.push<Map<String, dynamic>>('/taxi/map-picker');
                      if (result != null && mounted) {
                        final address = result['address'] as String;
                        final location = result['location'] as LatLng;
                        
                        if (_pickupFocusNode.hasFocus) {
                          _pickupController.text = address;
                          ref.read(taxiProvider.notifier).setPickup(location, address);
                          _dropoffFocusNode.requestFocus();
                        } else {
                          _dropoffController.text = address;
                          ref.read(taxiProvider.notifier).setDropoff(location, address);
                          _confirmAndNavigate();
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  if (_isSearching) const CircularProgressIndicator(strokeWidth: 2).animate().scale(),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),

            // Suggestions List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length + 1,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isPickup = _pickupFocusNode.hasFocus;
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      color: isPickup ? Colors.green.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05),
                      child: Row(
                        children: [
                          Icon(isPickup ? Iconsax.location : Iconsax.routing, size: 16, color: isPickup ? Colors.green : Colors.orange),
                          const SizedBox(width: 12),
                          Text(
                            isPickup ? 'Searching Pickup...' : 'Searching Drop...',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isPickup ? Colors.green[700] : Colors.orange[700]),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return _buildLocationItem(_searchResults[index - 1]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInput({required TextEditingController controller, required FocusNode focusNode, required String hint, required bool isPickup}) {
    final bool isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isFocused ? Colors.blue.withValues(alpha: 0.05) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isFocused ? Colors.blue : Colors.transparent, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black38), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.black12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
          ],
        ),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Iconsax.location, color: Colors.black45, size: 22),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc['name']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                    const SizedBox(height: 2),
                    Text(loc['address']!, style: const TextStyle(fontSize: 12, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Iconsax.add, color: Colors.black26, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _onLocationSelected(Map<String, dynamic> loc) {
    final latLng = LatLng(loc['lat'], loc['lng']);
    final name = loc['name'];

    if (_pickupFocusNode.hasFocus) {
      _pickupController.text = name;
      ref.read(taxiProvider.notifier).setPickup(latLng, name);
      _dropoffFocusNode.requestFocus();
    } else {
      _dropoffController.text = name;
      ref.read(taxiProvider.notifier).setDropoff(latLng, name);
      _confirmAndNavigate();
    }
  }

  void _confirmAndNavigate() {
    final state = ref.read(taxiProvider);
    if (state.pickupLocation != null && state.dropoffLocation != null) {
      context.push('/taxi/ride-options');
    }
  }
}

