import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

import '../../shared/widgets/live_map_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/widgets/rental_completion_dialog.dart';
import '../../providers/taxi_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../core/repositories/transaction_repository.dart';
import '../../core/models/transaction_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/payment_service.dart';
import '../../core/services/pricing_service.dart';
import '../../shared/widgets/sos_button.dart';
import 'dart:async';
import '../../core/services/osm_maps_service.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profile/user_provider.dart';
import '../profile/sos_provider.dart';

class TaxiRideScreen extends ConsumerStatefulWidget {
  const TaxiRideScreen({super.key});

  @override
  ConsumerState<TaxiRideScreen> createState() => _TaxiRideScreenState();
}

class _TaxiRideScreenState extends ConsumerState<TaxiRideScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropoffFocusNode = FocusNode();
  String _searchQuery = '';
  bool _showSuggestions = false;
  bool _isPickupSearch = true;
  int _completedRating = 0;
  bool _isBooking = false;

  final OSMMapsService _osmService = OSMMapsService();
  List<Map<String, dynamic>> _apiSearchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  List<Map<String, dynamic>> get _addressSuggestions {
    final state = ref.read(taxiProvider);
    final currentLoc = state.pickupLocation ?? const LatLng(12.9716, 77.5946);
    return [
      {
        'name': state.pickupAddress ?? 'Current Location',
        'address': 'Your current location',
        'lat': currentLoc.latitude,
        'lng': currentLoc.longitude
      },
      {
        'name': 'Old Airport Road',
        'address': 'Old Airport Road, Kodihalli, Bengaluru',
        'lat': 12.9610,
        'lng': 77.6487
      },
      {
        'name': 'MG Road Metro Station',
        'address': 'Mahatma Gandhi Road, Bengaluru',
        'lat': 12.9756,
        'lng': 77.6068
      },
      {
        'name': 'Indiranagar Double Road',
        'address': 'Indiranagar, Stage 2, Bengaluru',
        'lat': 12.9719,
        'lng': 77.6412
      },
      {
        'name': 'Koramangala 4th Block',
        'address': 'Koramangala, St. John\'s Hospital Road, Bengaluru',
        'lat': 12.9352,
        'lng': 77.6245
      },
      {
        'name': 'Whitefield Railway Station',
        'address': 'Kadugodi, Bengaluru',
        'lat': 12.9698,
        'lng': 77.7499
      },
      {
        'name': 'Majestic Bus Station',
        'address': 'Kempegowda Bus Station, Majestic, Bengaluru',
        'lat': 12.9779,
        'lng': 77.5724
      },
      {
        'name': 'Electronic City Phase 1',
        'address': 'Hosur Road, Bengaluru',
        'lat': 12.8497,
        'lng': 77.6749
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taxiProvider.notifier).initializeLocation();

      _pickupFocusNode.addListener(() {
        if (_pickupFocusNode.hasFocus) {
          setState(() {
            _showSuggestions = true;
            _searchQuery = ref.read(pickupControllerProvider).text;
            _isPickupSearch = true;
          });
          _sheetController.animateTo(0.85,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
          ref
              .read(taxiProvider.notifier)
              .updateStatus(RideStatus.selectingPickup);
        } else {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted &&
                !_pickupFocusNode.hasFocus &&
                !_dropoffFocusNode.hasFocus) {
              setState(() {
                _showSuggestions = false;
              });
            }
          });
        }
      });

      _dropoffFocusNode.addListener(() {
        if (_dropoffFocusNode.hasFocus) {
          setState(() {
            _showSuggestions = true;
            _searchQuery = ref.read(dropoffControllerProvider).text;
            _isPickupSearch = false;
          });
          _sheetController.animateTo(0.85,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
          ref
              .read(taxiProvider.notifier)
              .updateStatus(RideStatus.selectingDrop);
        } else {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted &&
                !_pickupFocusNode.hasFocus &&
                !_dropoffFocusNode.hasFocus) {
              setState(() {
                _showSuggestions = false;
              });
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sheetController.dispose();
    _pickupFocusNode.dispose();
    _dropoffFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _apiSearchResults = [];
        _isSearching = false;
      });
      return;
    }

    final taxiState = ref.read(taxiProvider);
    final biasLoc = taxiState.pickupLocation;

    if (query.length == 2) {
      _osmService.searchAddress(query, biasLocation: biasLoc).then((results) {
        if (mounted) {
          setState(() {
            _apiSearchResults = results;
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
          _apiSearchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiProvider);
    final taxiNotifier = ref.read(taxiProvider.notifier);
    final pickupController = ref.watch(pickupControllerProvider);
    final dropoffController = ref.watch(dropoffControllerProvider);
    final isOffline = ref.watch(connectivityProvider).value ?? false;

    // Sync controllers with state
    // Sync controllers with state ONLY if they are not currently focused to avoid jitter
    if (taxiState.pickupAddress != null &&
        pickupController.text != taxiState.pickupAddress &&
        !_pickupFocusNode.hasFocus) {
      pickupController.text = taxiState.pickupAddress!;
    }
    if (taxiState.dropoffAddress != null &&
        dropoffController.text != taxiState.dropoffAddress &&
        !_dropoffFocusNode.hasFocus) {
      dropoffController.text = taxiState.dropoffAddress!;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Live Map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: taxiState.status == RideStatus.idle ||
                  taxiState.status == RideStatus.selectingPickup,
              roadroboLocation: taxiState.roadroboLocation,
              showNearbyTaxis: true,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture &&
                    (taxiState.status == RideStatus.selectingPickup ||
                        taxiState.status == RideStatus.selectingDrop)) {
                  final center = camera.center;
                  if (taxiState.status == RideStatus.selectingPickup) {
                    taxiNotifier.setPickup(center, 'Map Pin Location');
                  } else {
                    taxiNotifier.setDropoff(center, 'Map Pin Location');
                  }
                }
              },
            ),
          ),

          // 2. Center Pin for Selection
          if (taxiState.status == RideStatus.selectingPickup ||
              taxiState.status == RideStatus.selectingDrop)
            _buildCenterPin(taxiState.status == RideStatus.selectingPickup),

          // 3. Safe Area Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildRoundedButton(
                      Icons.arrow_back, () => Navigator.pop(context)),
                  const Spacer(),
                  if (taxiState.status == RideStatus.tracking ||
                      taxiState.status == RideStatus.headingToDropoff)
                    _buildRoundedButton(Icons.share, () {
                      final pos = taxiState
                          .pickupLocation; // Using pickup as live loc for demo
                      if (pos != null) {
                        final link =
                            'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}';
                        ref.read(taxiProvider.notifier).shareTrip(link);
                      }
                    }),
                  const SizedBox(width: 12),
                  if ((taxiState.status == RideStatus.tracking ||
                          taxiState.status == RideStatus.atPickup ||
                          taxiState.status == RideStatus.headingToDropoff) &&
                      !isOffline)
                    _buildETAIndicator(taxiState.eta ?? 'Calculating...'),
                  if (isOffline)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off, color: Colors.white, size: 14),
                          SizedBox(width: 8),
                          Text('Live updates paused',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Main UI Overlay based on Status
          _buildBottomUI(context, taxiState, taxiNotifier, pickupController,
              dropoffController),

          // 3b. SOS Button Overlay (Visible during tracking/ride)
          if (taxiState.status == RideStatus.tracking ||
              taxiState.status == RideStatus.atPickup ||
              taxiState.status == RideStatus.headingToDropoff)
            Positioned(
              right: 20,
              bottom: MediaQuery.of(context).size.height * 0.45 +
                  20, // Sit above the sheet
              child: SOSButton(
                onTrigger: () {
                  final userId = ref.read(userProvider).user?.id ?? 'demo';
                  ref.read(sosProvider.notifier).triggerEmergency(userId);
                },
              ),
            ).animate().fadeIn().scale(),

          // 4. Booking Shimmer Overlay
          if (taxiState.status == RideStatus.booked) _buildBookingShimmer(),
        ],
      ),
    );
  }

  Widget _buildBottomUI(
    BuildContext context,
    TaxiState state,
    TaxiNotifier notifier,
    TextEditingController pickupCtrl,
    TextEditingController dropoffCtrl,
  ) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: (state.status == RideStatus.selectingPickup ||
              state.status == RideStatus.selectingDrop)
          ? 0.85
          : (state.status == RideStatus.idle ? 0.35 : 0.45),
      minChildSize: 0.3,
      maxChildSize: 0.9,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDarkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              if (state.status == RideStatus.idle ||
                  state.status == RideStatus.selectingPickup ||
                  state.status == RideStatus.selectingDrop ||
                  state.status == RideStatus.vehicleSelection)
                _buildSearchSection(state, notifier, pickupCtrl, dropoffCtrl),
              if (state.status == RideStatus.tracking)
                _buildTrackingSection(state, notifier),
              if (state.status == RideStatus.atPickup)
                _buildAtPickupSection(state, notifier),
              if (state.status == RideStatus.headingToDropoff)
                _buildHeadingToDropSection(state, notifier),
              if (state.status == RideStatus.completed)
                _buildCompletedSection(state, notifier),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(TaxiState state, TaxiNotifier notifier,
      TextEditingController pCtrl, TextEditingController dCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Your Ride',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          label: 'Pickup Location',
          hint: 'Select pickup point',
          controller: pCtrl,
          prefixIcon: Iconsax.location,
          focusNode: _pickupFocusNode,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
              _showSuggestions = true;
            });
            _onSearchChanged(val);
            notifier.updateStatus(RideStatus.selectingPickup);
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Destination',
          hint: 'Where to?',
          controller: dCtrl,
          prefixIcon: Iconsax.routing,
          focusNode: _dropoffFocusNode,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
              _showSuggestions = true;
            });
            _onSearchChanged(val);
            notifier.updateStatus(RideStatus.selectingDrop);
          },
        ),
        if (_showSuggestions)
          _buildSuggestionsSection(state, notifier, pCtrl, dCtrl),
        const SizedBox(height: 32),
        if (state.status == RideStatus.vehicleSelection) ...[
          _buildFareEstimate(state, notifier),
          const SizedBox(height: 16),
          // Payment methods row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Row(children: [
                Icon(Icons.money, color: Colors.green, size: 20),
                SizedBox(width: 4),
                Text('Cash', style: TextStyle(fontWeight: FontWeight.bold))
              ]),
              Container(width: 1, height: 20, color: Colors.grey),
              const Row(children: [
                Icon(Icons.local_offer, color: Colors.green, size: 20),
                SizedBox(width: 4),
                Text('Coupon', style: TextStyle(fontWeight: FontWeight.bold))
              ]),
              Container(width: 1, height: 20, color: Colors.grey),
              const Row(children: [
                Icon(Icons.person, color: Colors.grey, size: 20),
                SizedBox(width: 4),
                Text('Myself', style: TextStyle(fontWeight: FontWeight.bold))
              ]),
            ],
          ),
          const SizedBox(height: 16),
        ],
        CustomButton(
          label: state.status == RideStatus.vehicleSelection
              ? 'Book ${state.selectedOption?.title ?? 'Ride'}'
              : 'SELECT LOCATIONS',
          onPressed: (state.status == RideStatus.booked || _isBooking)
              ? null
              : () async {
                  _triggerHaptic();
                  if (state.status == RideStatus.vehicleSelection) {
                    setState(() => _isBooking = true);
                    await notifier.bookRide();
                    if (mounted) setState(() => _isBooking = false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please select both locations')));
                  }
                },
          isLoading: state.status == RideStatus.booked || _isBooking,
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildAtPickupSection(TaxiState state, TaxiNotifier notifier) {
    return Column(
      children: [
        const Icon(Icons.location_on, color: Colors.green, size: 48)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
        const SizedBox(height: 12),
        Text(
          '${state.roadroboName ?? 'Roadrobo'} has arrived!',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Show OTP to driver: ${state.otp ?? '----'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        CustomButton(
          label: 'Start Trip',
          onPressed: () {
            _triggerHaptic();
            notifier.startTrip();
          },
          backgroundColor: Colors.green,
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildHeadingToDropSection(TaxiState state, TaxiNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'On Your Way!',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.flag, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.dropoffAddress ?? 'Your Destination',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (state.eta != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(state.eta!,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue)),
            ],
          ),
        ],
        const SizedBox(height: 24),
        CustomButton(
          label: 'ARRIVED AT DESTINATION',
          onPressed: () {
            _triggerHaptic();
            notifier.completeRide();
            _showCompletionDialog(context, notifier);
          },
          backgroundColor: AppColors.errorRed,
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSuggestionsSection(TaxiState state, TaxiNotifier notifier,
      TextEditingController pCtrl, TextEditingController dCtrl) {
    // Filter suggestions based on what the user types
    final filtered = _addressSuggestions.where((s) {
      final name = s['name'].toString().toLowerCase();
      final address = s['address'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return query.isEmpty || name.contains(query) || address.contains(query);
    }).toList();

    final displayList = [...filtered, ..._apiSearchResults];

    if (displayList.isEmpty && !_isSearching) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'SUGGESTIONS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Searching...',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.grey)),
              ],
            ),
          ),
        Container(
          constraints: const BoxConstraints(maxHeight: 250),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              height: 1,
            ),
            itemBuilder: (context, index) {
              final suggestion = displayList[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  suggestion['name'],
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  suggestion['address'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  final latLng = LatLng(suggestion['lat'], suggestion['lng']);
                  final name = suggestion['name'];

                  if (_isPickupSearch) {
                    pCtrl.text = name;
                    notifier.setPickup(latLng, name);
                  } else {
                    dCtrl.text = name;
                    notifier.setDropoff(latLng, name);
                  }

                  // Unfocus all fields
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _showSuggestions = false;
                    _searchQuery = '';
                  });
                  _sheetController.animateTo(
                    state.status == RideStatus.vehicleSelection ? 0.45 : 0.35,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFareEstimate(TaxiState state, TaxiNotifier notifier) {
    if (state.rideOptions.isEmpty) return const SizedBox.shrink();

    if (state.selectedOption == null && state.rideOptions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.selectOption(state.rideOptions.first);
      });
    }

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.rideOptions.length,
        separatorBuilder: (context, index) => Divider(
            height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
        itemBuilder: (context, index) {
          final option = state.rideOptions[index];
          final isSelected = state.selectedOption?.id == option.id;

          return GestureDetector(
            onTap: () => notifier.selectOption(option),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryBlue : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  if (option.assetPath != null)
                    Image.asset(option.assetPath!, width: 40, height: 40)
                  else
                    Icon(option.icon,
                        size: 40,
                        color: isDark ? Colors.white : AppColors.primaryNavy),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(option.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary)),
                            if (option.tag != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(option.tag!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(option.subtitle,
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('₹${option.price.toInt()}',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color:
                              isDark ? Colors.white : AppColors.textPrimary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackingSection(TaxiState state, TaxiNotifier notifier) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Roadrobo Arriving',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8)),
                child: Text('OTP: ${state.otp}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green))),
          ],
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Row(
            children: [
              const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.bgLightAlt,
                  child: Icon(Iconsax.user, color: AppColors.primaryBlue)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.roadroboName ?? 'Roadrobo',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      state.selectedOption?.title ?? 'Vehicle',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.message, color: AppColors.primaryBlue),
                onPressed: () {
                  final rideId = state.rideId ?? '';
                  final driverId = state.driverId ?? '';
                  final driverName = state.roadroboName ?? 'Roadrobo';
                  context.push('/chat', extra: {
                    'bookingId': rideId,
                    'receiverId': driverId,
                    'receiverName': driverName,
                  });
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.call, color: AppColors.primaryBlue),
                onPressed: () async {
                  final Uri url = Uri(scheme: 'tel', path: '+919876543210');
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    final success = await launchUrl(url);
                    if (!success) {
                      scaffoldMessenger.showSnackBar(const SnackBar(
                          content: Text('Could not launch dialer')));
                    }
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(const SnackBar(
                        content: Text('Could not launch dialer')));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        CustomButton(
          label: 'ARRIVED? END TRIP',
          onPressed: () {
            _triggerHaptic();
            notifier.completeRide();
            _showCompletionDialog(context, notifier);
          },
          backgroundColor: AppColors.errorRed,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            _triggerHaptic();
            _showCancelDialog(context, notifier);
          },
          child: const Text(
            'Cancel Ride',
            style: TextStyle(
              color: AppColors.errorRed,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildCompletedSection(TaxiState state, TaxiNotifier notifier) {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        Text(
          'Ride Completed!',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        const Text('How was your experience?',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                _triggerHaptic();
                setState(() => _completedRating = index + 1);
              },
              child: Icon(
                index < _completedRating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: index < _completedRating
                    ? Colors.amber
                    : Colors.amber.withValues(alpha: 0.3),
                size: 36,
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        CustomButton(
          label: 'BOOK NEXT RIDE',
          onPressed: () {
            notifier.reset();
            context.go('/main/home');
          },
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildBookingShimmer() {
    return Container(
      color: Colors.white.withValues(alpha: 0.8),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerLoading(height: 60, width: 60, borderRadius: 30),
              SizedBox(height: 32),
              ShimmerLoading(height: 20, width: 200),
              SizedBox(height: 12),
              ShimmerLoading(height: 15, width: 150),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildRoundedButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkSurface : Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Icon(icon,
            size: 20, color: isDark ? Colors.white : AppColors.textPrimary),
      ),
    );
  }

  Widget _buildETAIndicator(String eta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.black87, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Text(eta,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCenterPin(bool isPickup) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40), // Offset for pin tip
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Text(
                isPickup ? 'PICKUP HERE' : 'SET DESTINATION',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.location_on, size: 44, color: AppColors.errorRed),
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  void _showCancelDialog(BuildContext context, TaxiNotifier notifier) {
    String selectedReason = '';
    final reasons = [
      'Expected a shorter wait time',
      'Driver asked me to cancel',
      'Driver is too far away',
      'I changed my mind',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom:
                    MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cancel Ride',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.textOnDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please let us know why you are canceling.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textOnDarkMuted
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map((reason) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedReason = reason;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          children: [
                            Icon(
                              selectedReason == reason
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: selectedReason == reason
                                  ? AppColors.primaryBlue
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textOnDark
                                      : AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side:
                                const BorderSide(color: AppColors.primaryBlue),
                          ),
                          child: const Text('Keep Ride',
                              style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          label: 'Cancel Ride',
                          onPressed: () async {
                            if (selectedReason.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please select a reason first')),
                              );
                              return;
                            }
                            // Log cancellation reason before resetting state
                            final rideId = ref.read(taxiProvider).rideId;
                            if (rideId != null && rideId.isNotEmpty) {
                              try {
                                await Supabase.instance.client
                                    .from('ride_bookings')
                                    .update({
                                  'status': 'cancelled',
                                  'cancellation_reason': selectedReason,
                                  'cancelled_at':
                                      DateTime.now().toIso8601String(),
                                }).eq('id', rideId);
                              } catch (e) {
                                debugPrint(
                                    'Failed to log cancellation reason: $e');
                              }
                            }
                            notifier.cancelRide();
                            if (context.mounted) {
                              Navigator.pop(bottomSheetContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Ride cancelled: $selectedReason'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          backgroundColor: selectedReason.isEmpty
                              ? Colors.grey
                              : AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCompletionDialog(BuildContext context, TaxiNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RentalCompletionDialog(
        vehicleName: 'Motorcycle',
        onCompletePayment: () async {
          final userData = ref.read(userProvider).user;
          final state = ref.read(taxiProvider);
          final basePrice = state.selectedOption?.price ?? 145.0;
          final breakdown = PricingService.calculateBill(basePrice);
          final userId = userData?.id ?? 'demo';

          try {
            await ref
                .read(paymentServiceProvider.notifier)
                .startPayment(PaymentDetails(
                  bookingId:
                      state.rideId ?? '00000000-0000-0000-0000-000000000000',
                  bookingType: BookingType.ride,
                  totalCost: breakdown.totalPayable,
                  userId: userId,
                  contact: userData?.phone ?? '9876543210',
                  email: userData?.email ?? 'customer@example.com',
                  description: 'Taxi Ride Payment',
                ));

            // On success
            await ref
                .read(transactionRepositoryProvider)
                .logTransaction(AppTransaction(
                  id: '',
                  userId: userId,
                  razoprayPaymentId: 'VERIFIED_ON_SERVER',
                  baseAmount: breakdown.baseAmount,
                  gstAmount: breakdown.gstAmount,
                  platformFee: breakdown.platformFee,
                  handlingCharges: breakdown.handlingCharges,
                  totalAmount: breakdown.totalPayable,
                  description:
                      'Taxi Ride: ${state.pickupAddress} to ${state.dropoffAddress}',
                  timestamp: DateTime.now(),
                ));

            ref.read(taxiProvider.notifier).reset();
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppColors.errorRed,
              ));
            }
          }
        },
        onReschedule: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
