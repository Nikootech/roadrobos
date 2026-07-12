# 🚀 TASK: Fix Ride Booking Module — RoadRobos Flutter App
> **For the AI reading this:** This is a complete, self-contained task file. Read every section before writing any code. All context, exact file paths, current code, and required fixes are included here.

---

## 📁 Project Context

- **App:** RoadRobos — a Flutter ride-booking + vehicle service app (like Ola/Uber)
- **Root:** `e:\roadrobosapp\android app\`
- **Language:** Dart / Flutter
- **State Management:** Riverpod (`StateNotifier` pattern)
- **Navigation:** `go_router` ^13.0.0
- **Backend:** Supabase (PostgreSQL + Realtime)
- **Payments:** Razorpay
- **Maps:** flutter_map + OpenStreetMap (OSM)

---

## 🗺️ Key Files — Ride Module

| File | Role |
|------|------|
| `lib/providers/taxi_provider.dart` | Core state: `TaxiState`, `TaxiNotifier`, `RideStatus` enum, `RideOption` model |
| `lib/features/taxi/taxi_ride_screen.dart` | All-in-one ride screen (idle → search → options → tracking → complete) |
| `lib/features/rides/book_ride_screen.dart` | Entry point screen shown when tapping "Book Ride" from home |
| `lib/features/rides/ride_options_screen.dart` | Vehicle selection screen (Bike/Auto/Cab) |
| `lib/features/rides/live_tracking_screen.dart` | Driver searching + live tracking screen |
| `lib/features/rides/ride_complete_screen.dart` | Post-ride: fare, rating, done |
| `lib/features/rides/location_search_screen.dart` | Pickup/dropoff search with OSM autocomplete |
| `lib/navigation/routes/customer_routes.dart` | GoRouter route definitions |

---

## 🔴 RideStatus Flow (How States Should Progress)

```
idle → selectingPickup → selectingDrop → vehicleSelection → booked → tracking → atPickup → headingToDropoff → completed
```

---

## ✅ TASK LIST — Fix All 23 Bugs

Complete every task in order. Mark `[x]` when done.

---

### TASK 1 — Fix Double Booking in `startSearching()`
**File:** `lib/providers/taxi_provider.dart`
**Lines:** 506–509

**Problem:** `startSearching()` sets `status = booked`, then calls `bookRide()` which ALSO sets `status = booked`. This creates a double state update and risks a double Supabase insert.

**Current code (broken):**
```dart
Future<bool> startSearching() async {
  state = state.copyWith(status: RideStatus.booked);
  return await bookRide();
}
```

**Fix — replace with:**
```dart
Future<bool> startSearching() async {
  // Do NOT set booked here — bookRide() handles status internally
  return await bookRide();
}
```

---

### TASK 2 — Add 90-Second Driver Search Timeout
**File:** `lib/providers/taxi_provider.dart`
**Location:** Inside `bookRide()` method, after `_rideSubscription` is set up (around line 357)

**Problem:** If no driver accepts within the `Future.delayed(4s)` window, the booking stays `RideStatus.booked` forever. The user sees an infinite spinner.

**Add this Timer field to the class (near line 141):**
```dart
Timer? _searchTimeoutTimer;
```

**Add this to the `dispose()` method:**
```dart
@override
void dispose() {
  _searchTimeoutTimer?.cancel(); // ADD THIS
  _rideSubscription?.cancel();
  _driverLocationSubscription?.cancel();
  super.dispose();
}
```

**Replace `cancelRide()` method (line 502–504) with:**
```dart
void cancelRide() {
  _cancelBookingOnBackend(); // cancel in Supabase
  _searchTimeoutTimer?.cancel();
  reset();
}
```

**Add this new private method anywhere in the class:**
```dart
Future<void> _cancelBookingOnBackend() async {
  final bookingId = state.rideId;
  if (bookingId == null || bookingId.isEmpty) return;
  try {
    await ref.read(rideBookingRepositoryProvider).cancelBooking(bookingId);
  } catch (e) {
    debugPrint('Failed to cancel booking on backend: $e');
  }
}
```

**Inside `bookRide()`, AFTER the `_rideSubscription` setup block (after line ~356), ADD:**
```dart
// 90-second search timeout
_searchTimeoutTimer?.cancel();
_searchTimeoutTimer = Timer(const Duration(seconds: 90), () {
  if (state.status == RideStatus.booked) {
    _cancelBookingOnBackend();
    state = state.copyWith(status: RideStatus.idle);
    debugPrint('TaxiProvider: Driver search timed out after 90s');
  }
});
```

**Also cancel the timer when driver is assigned — inside `_onDriverAssigned()` (line 376), add as first line:**
```dart
_searchTimeoutTimer?.cancel();
```

**Also cancel on complete — inside `completeRide()` (line 406), add:**
```dart
_searchTimeoutTimer?.cancel();
```

---

### TASK 3 — Fix Cancel Ride to Actually Cancel in Supabase
**File:** `lib/features/rides/live_tracking_screen.dart`
**Lines:** 150–154

**Problem:** Cancel button only clears local state. The booking stays `pending` in Supabase.

**Current code:**
```dart
onTap: () {
  ref.read(taxiProvider.notifier).cancelRide();
  context.go('/main/home');
},
```

**Fix:** The `cancelRide()` method in taxi_provider.dart now calls `_cancelBookingOnBackend()` (from TASK 2). No change needed here IF TASK 2 is done. But also update UI to show cancellation feedback:

```dart
onTap: () async {
  ref.read(taxiProvider.notifier).cancelRide();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ride cancelled'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/main/home');
  }
},
```

**ALSO** — you need to add a `cancelBooking` method to `RideBookingRepository`.
**File:** `lib/core/repositories/ride_booking_repository.dart`
Find the class and add this method:
```dart
Future<void> cancelBooking(String bookingId) async {
  await Supabase.instance.client
      .from('ride_bookings')
      .update({'status': 'cancelled', 'cancelled_at': DateTime.now().toIso8601String()})
      .eq('id', bookingId);
}
```

---

### TASK 4 — Fix Cancel Dialog to Submit Reason to Backend
**File:** `lib/features/taxi/taxi_ride_screen.dart`
**Lines:** 869–880

**Problem:** Cancel reason is selected but never sent to Supabase.

**Current code:**
```dart
onPressed: () {
  if (selectedReason.isEmpty) { ... return; }
  notifier.cancelRide();
  Navigator.pop(bottomSheetContext);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Ride canceled: $selectedReason')),
  );
},
```

**Fix — replace the onPressed block:**
```dart
onPressed: () async {
  if (selectedReason.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a reason first')),
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
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rideId);
    } catch (e) {
      debugPrint('Failed to log cancellation reason: $e');
    }
  }
  notifier.cancelRide();
  if (context.mounted) Navigator.pop(bottomSheetContext);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ride cancelled: $selectedReason'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
},
```

**Add import at top of `taxi_ride_screen.dart` if not present:**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

---

### TASK 5 — Fix `RideOptionsScreen` Hardcoded Default Selection
**File:** `lib/features/rides/ride_options_screen.dart`
**Lines:** 17–31

**Problem:** Local `_selectedRide` is hardcoded to `Bike @ ₹47` in `initState`. This ignores the real dynamic prices from `taxiProvider`.

**Current code:**
```dart
RideOption? _selectedRide;

@override
void initState() {
  super.initState();
  _selectedRide = RideOption(
    id: 'bike',
    title: 'Bike',
    price: 47,
    subtitle: '1 min away • Drop 1:05 pm',
    icon: Icons.motorcycle,
  );
}
```

**Fix — replace with:**
```dart
RideOption? _selectedRide;

@override
void initState() {
  super.initState();
  // Defer selection to first frame so we can read provider
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final options = ref.read(taxiProvider).rideOptions;
    if (options.isNotEmpty && mounted) {
      setState(() {
        _selectedRide = options.first; // use real first option with real price
        ref.read(taxiProvider.notifier).selectOption(options.first);
      });
    }
  });
}
```

---

### TASK 6 — Fix `atPickup` and `headingToDropoff` Blank Bottom Sheet
**File:** `lib/features/taxi/taxi_ride_screen.dart`
**Lines:** 288–299 inside `_buildBottomUI()`

**Problem:** These two statuses render nothing in the bottom sheet — blank white sheet shows.

**Current code (inside `ListView` children):**
```dart
if (state.status == RideStatus.idle || 
    state.status == RideStatus.selectingPickup || 
    state.status == RideStatus.selectingDrop ||
    state.status == RideStatus.vehicleSelection)
  _buildSearchSection(state, notifier, pickupCtrl, dropoffCtrl),

if (state.status == RideStatus.tracking)
  _buildTrackingSection(state, notifier),
  
if (state.status == RideStatus.completed)
  _buildCompletedSection(state, notifier),
```

**Fix — add these two missing states:**
```dart
if (state.status == RideStatus.idle || 
    state.status == RideStatus.selectingPickup || 
    state.status == RideStatus.selectingDrop ||
    state.status == RideStatus.vehicleSelection)
  _buildSearchSection(state, notifier, pickupCtrl, dropoffCtrl),

if (state.status == RideStatus.tracking)
  _buildTrackingSection(state, notifier),

if (state.status == RideStatus.atPickup)        // ADD THIS
  _buildAtPickupSection(state, notifier),        // ADD THIS

if (state.status == RideStatus.headingToDropoff) // ADD THIS
  _buildHeadingToDropSection(state, notifier),   // ADD THIS
  
if (state.status == RideStatus.completed)
  _buildCompletedSection(state, notifier),
```

**Add these two new widget methods to `_TaxiRideScreenState` class:**
```dart
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
            Text(state.eta!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
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
```

---

### TASK 7 — Fix ETA Calculation Math (BUG-20)
**File:** `lib/providers/taxi_provider.dart`
**Lines:** 394–400 inside `_onDriverAssigned()` listener

**Problem:** `meters / 200` assumes 200 m/s = 720 km/h. Should use realistic city speed.

**Current code:**
```dart
final int etaMins = (meters / 200).ceil(); // Wrong! 200 m/s is 720 km/h
```

**Fix:**
```dart
// Assume avg city speed of 20 km/h = 333 m/min
final int etaMins = (meters / 333).ceil().clamp(1, 120);
```

---

### TASK 8 — Fix Hardcoded OTP `'1234'` in `acceptRideRequest()`
**File:** `lib/providers/taxi_provider.dart`
**Lines:** 240–250

**Problem:** `acceptRideRequest()` hardcodes `otp: '1234'`.

**Current code:**
```dart
otp: '1234',
```

**Fix:**
```dart
otp: (1000 + Random().nextInt(9000)).toString(), // 4-digit random OTP
```

Make sure `import 'dart:math';` is at top (it already is).

---

### TASK 9 — Fix `RideCompleteScreen` Hardcoded Stats & Driver Name
**File:** `lib/features/rides/ride_complete_screen.dart`
**Lines:** 131–133, 143

**Fix line 131–133 — replace hardcoded stats:**
```dart
// BEFORE (hardcoded):
_buildStatItem('Distance', '4.2 km', Icons.directions_rounded),
_buildStatItem('Time', '18 mins', Icons.access_time_rounded),
_buildStatItem('Co2 Saved', '1.2 kg', Icons.eco_rounded),

// AFTER (dynamic from taxiState):
_buildStatItem(
  'Distance',
  '${taxiState.distance.toStringAsFixed(1)} km',
  Icons.directions_rounded,
),
_buildStatItem(
  'ETA',
  taxiState.eta ?? '-- mins',
  Icons.access_time_rounded,
),
_buildStatItem(
  'Vehicle',
  taxiState.selectedOption?.title ?? 'Ride',
  Icons.electric_rickshaw,
),
```

**Fix line 143 — replace hardcoded driver name:**
```dart
// BEFORE:
const Text('How was your trip with Sohan?', ...),

// AFTER:
Text(
  'How was your trip with ${taxiState.roadroboName ?? 'your driver'}?',
  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy, fontSize: 16),
),
```

---

### TASK 10 — Fix Rating Stars — Track State & Submit to Supabase
**File:** `lib/features/rides/ride_complete_screen.dart`

The `_selectedRating` field already exists (line 19). The star display is correct.

**Problem:** Rating is never submitted when "DONE" is tapped.

**Fix the DONE button's `onPressed` (line 163–167):**
```dart
onPressed: () async {
  // Submit rating to Supabase if a ride exists
  final rideId = ref.read(taxiProvider).rideId;
  if (rideId != null && rideId.isNotEmpty && _selectedRating > 0) {
    try {
      await Supabase.instance.client
          .from('ride_bookings')
          .update({'customer_rating': _selectedRating})
          .eq('id', rideId);
    } catch (e) {
      debugPrint('Failed to submit rating: $e');
    }
  }
  ref.read(taxiProvider.notifier).reset();
  if (context.mounted) context.go('/main/home');
},
```

**Add import at top if missing:**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

---

### TASK 11 — Fix Rating Stars in `TaxiRideScreen` Completed Section
**File:** `lib/features/taxi/taxi_ride_screen.dart`
**Lines:** 680–690

**Problem:** Stars always show `Icons.star_border_rounded` (empty). No state tracking. No Supabase submit.

**Add a state variable to `_TaxiRideScreenState`:**
```dart
int _completedRating = 0; // ADD NEAR TOP OF STATE CLASS
```

**Replace the star row (lines 680–690):**
```dart
// BEFORE:
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(5, (index) => IconButton(
    icon: Icon(Icons.star_border_rounded, color: Colors.amber.withValues(alpha: 0.4), size: 32),
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(...);
    },
  )),
),

// AFTER:
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(5, (index) {
    return GestureDetector(
      onTap: () {
        _triggerHaptic();
        setState(() => _completedRating = index + 1);
      },
      child: Icon(
        index < _completedRating ? Icons.star_rounded : Icons.star_border_rounded,
        color: index < _completedRating ? Colors.amber : Colors.amber.withValues(alpha: 0.3),
        size: 36,
      ),
    );
  }),
),
```

---

### TASK 12 — Fix Phone Call Button in `LiveTrackingScreen`
**File:** `lib/features/rides/live_tracking_screen.dart`
**Line:** 278

**Problem:** `onTap: () {}` — does nothing.

**Add import at top:**
```dart
import 'package:url_launcher/url_launcher.dart';
```

**Fix:**
```dart
// BEFORE:
_buildCircleAction(Icons.call_rounded, Colors.green, onTap: () {}),

// AFTER:
_buildCircleAction(Icons.call_rounded, Colors.green, onTap: () async {
  final phone = '+919876543210'; // TODO: use real driver phone from state when backend provides it
  final uri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open dialer on this device')),
      );
    }
  }
}),
```

---

### TASK 13 — Fix Hardcoded Vehicle Info in `TaxiRideScreen` Tracking Section
**File:** `lib/features/taxi/taxi_ride_screen.dart`
**Line:** 600

**Current:**
```dart
const Text('Suzuki Gixxer • KA 01 EB 4567', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
```

**Fix:**
```dart
Text(
  state.selectedOption?.title ?? 'Vehicle',
  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
),
```

The actual vehicle plate number and model will need to come from the driver profile in a future Supabase query. For now, show the vehicle type selected by the user.

---

### TASK 14 — Fix `BookRideScreen` Recent Location Tap — Validate Pickup First
**File:** `lib/features/rides/book_ride_screen.dart`
**Lines:** 209–215

**Problem:** Tapping a recent location sets the dropoff and immediately navigates to `/taxi/ride-options` without checking if pickup location is set. If `pickupLocation == null`, `_calculateDistance()` fails silently.

**Current code:**
```dart
onTap: () {
  final lat = loc['lat'] as double;
  final lng = loc['lng'] as double;
  final latLng = LatLng(lat, lng);
  ref.read(taxiProvider.notifier).setDropoff(latLng, title);
  context.push('/taxi/ride-options');
},
```

**Fix:**
```dart
onTap: () async {
  final lat = loc['lat'] as double;
  final lng = loc['lng'] as double;
  final latLng = LatLng(lat, lng);

  // Ensure pickup location is available
  final currentState = ref.read(taxiProvider);
  if (currentState.pickupLocation == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please wait — fetching your current location...'),
        duration: Duration(seconds: 2),
      ),
    );
    await ref.read(taxiProvider.notifier).initializeLocation();
  }

  ref.read(taxiProvider.notifier).setDropoff(latLng, title);
  if (context.mounted) context.push('/taxi/ride-options');
},
```

---

### TASK 15 — Fix Driver Search Timeout UI in `LiveTrackingScreen`
**File:** `lib/features/rides/live_tracking_screen.dart`

**Problem:** When `taxiProvider` status returns to `idle` after the 90-second timeout (TASK 2), the `LiveTrackingScreen` still sits there with no navigation or message.

**Add a `ref.listen` at the start of the `build()` method (inside `_LiveTrackingScreenState`):**
```dart
@override
Widget build(BuildContext context) {
  // Listen for timeout — if status goes back to idle, show message and pop
  ref.listen<TaxiState>(taxiProvider, (previous, next) {
    if (previous?.status == RideStatus.booked && next.status == RideStatus.idle) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No drivers available nearby. Please try again.'),
            backgroundColor: Colors.deepOrange,
            duration: Duration(seconds: 4),
          ),
        );
        context.pop(); // go back to ride options
      }
    }
  });

  final taxiState = ref.watch(taxiProvider);
  // ... rest of build method unchanged
```

---

### TASK 16 — Make Payment Method Selection Interactive
**File:** `lib/features/rides/ride_options_screen.dart`
**Lines:** 146–153

**Problem:** Cash/Coupons/Myself row is purely decorative text, no tap handlers.

**Add state variable to `_RideOptionsScreenState`:**
```dart
String _paymentMethod = 'Cash'; // default
```

**Replace the footer row:**
```dart
// BEFORE (static):
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildFooterOption(Icons.money, 'Cash'),
    Container(width: 1, height: 20, color: Colors.grey[300]),
    _buildFooterOption(Icons.local_offer_outlined, 'Coupons'),
    Container(width: 1, height: 20, color: Colors.grey[300]),
    _buildFooterOption(Icons.person_outline, 'Myself'),
  ],
),

// AFTER (interactive):
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    GestureDetector(
      onTap: () => setState(() => _paymentMethod = 'Cash'),
      child: _buildFooterOption(
        Icons.money,
        'Cash',
        isSelected: _paymentMethod == 'Cash',
      ),
    ),
    Container(width: 1, height: 20, color: Colors.grey[300]),
    GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon feature coming soon!')),
        );
      },
      child: _buildFooterOption(Icons.local_offer_outlined, 'Coupons'),
    ),
    Container(width: 1, height: 20, color: Colors.grey[300]),
    GestureDetector(
      onTap: () => setState(() => _paymentMethod = 'Myself'),
      child: _buildFooterOption(
        Icons.person_outline,
        'Myself',
        isSelected: _paymentMethod == 'Myself',
      ),
    ),
  ],
),
```

**Update `_buildFooterOption()` to accept selection state:**
```dart
Widget _buildFooterOption(IconData icon, String label, {bool isSelected = false}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20, color: isSelected ? AppColors.primaryBlue : Colors.black87),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: isSelected ? AppColors.primaryBlue : Colors.black87,
        ),
      ),
      const SizedBox(width: 2),
      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
    ],
  );
}
```

---

### TASK 17 — Fix `autoDispose` Controller Loss on Navigation
**File:** `lib/providers/taxi_provider.dart`
**Lines:** 528–538

**Problem:** `pickupControllerProvider` and `dropoffControllerProvider` are `autoDispose`. When the user navigates away (e.g. to `/chat`) and comes back, the providers are destroyed and recreated — losing the typed text even though `taxiProvider` still holds the addresses.

**Fix — remove `autoDispose`:**
```dart
// BEFORE:
final pickupControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final dropoffControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

// AFTER:
final pickupControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final dropoffControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});
```

---

### TASK 18 — Fix Completion Dialog Using Wrong Booking UUID
**File:** `lib/features/taxi/taxi_ride_screen.dart`
**Line:** 912

**Problem:** Payment booking ID is hardcoded to `'00000000-0000-0000-0000-000000000000'` instead of the actual booking ID from state.

**Current:**
```dart
bookingId: '00000000-0000-0000-0000-000000000000', // Taxi booking UUID
```

**Fix:**
```dart
bookingId: state.rideId ?? '00000000-0000-0000-0000-000000000000',
```

---

### TASK 19 — Add "Book Next Ride" Navigation After Completion
**File:** `lib/features/taxi/taxi_ride_screen.dart`
**Lines:** 692–695 inside `_buildCompletedSection()`

**Problem:** "BOOK NEXT RIDE" only calls `notifier.reset()` but doesn't navigate anywhere.

**Current:**
```dart
CustomButton(
  label: 'BOOK NEXT RIDE',
  onPressed: () => notifier.reset(),
),
```

**Fix:**
```dart
CustomButton(
  label: 'BOOK NEXT RIDE',
  onPressed: () {
    notifier.reset();
    context.go('/main/home'); // go back to home so user can start fresh
  },
),
```

---

## ✅ VERIFICATION CHECKLIST

After all tasks are complete, test this complete flow:

1. **[ ]** Open app → tap "Book Ride" or "Taxi"
2. **[ ]** Location auto-detected or tap to set pickup
3. **[ ]** Type/select destination — prices load dynamically (not ₹47 hardcoded)
4. **[ ]** Select vehicle option — price matches selected vehicle
5. **[ ]** Tap "Book" — shows searching screen
6. **[ ]** After 90 seconds with no driver: app returns to idle with snackbar message (timeout test)
7. **[ ]** Cancel button on tracking screen: confirms cancellation + redirects home
8. **[ ]** When driver assigned: status shows `tracking` section (not blank)
9. **[ ]** When driver arrives: status shows `atPickup` section with OTP
10. **[ ]** OTP shown correctly (not `----` or `4582` hardcoded)
11. **[ ]** Tap "Start Trip" → status shows `headingToDropoff` section
12. **[ ]** `headingToDropoff` section shows destination + ETA (not blank)
13. **[ ]** Tap "ARRIVED AT DESTINATION" → `RideCompleteScreen` opens
14. **[ ]** Ride Complete shows real distance, real vehicle type, real driver name
15. **[ ]** Rate stars: tap 3 stars → 3 filled stars shown (not all empty)
16. **[ ]** Tap DONE → rating submitted to Supabase, navigate to home
17. **[ ]** Call button on tracking screen opens dialer
18. **[ ]** Cancel dialog: select reason → tapping Cancel submits reason to Supabase

---

## 📋 IMPORT REFERENCE

These imports may need to be added to files:

**For Supabase calls:**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

**For url_launcher (phone calls):**
```dart
import 'package:url_launcher/url_launcher.dart';
```

**For Timer:**
```dart
import 'dart:async';
```

**For Random:**
```dart
import 'dart:math';
```

Both `url_launcher` and `supabase_flutter` are already in `pubspec.yaml` — no new packages needed.

---

## ⚠️ DO NOT CHANGE

- Do NOT change `RideStatus` enum values
- Do NOT change `TaxiState` model field names
- Do NOT change route paths in `customer_routes.dart`
- Do NOT change `Supabase` table name `ride_bookings` — it's used by the backend
- Do NOT change the `go_router` route structure

---

## 🏁 DONE CRITERIA

All tasks marked `[x]`, the app compiles without errors, and the full booking flow from VERIFICATION CHECKLIST steps 1–18 works end-to-end.
