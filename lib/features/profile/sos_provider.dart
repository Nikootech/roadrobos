import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/extensions/datetime_extensions.dart';

class SosContact {
  final String name;
  final String phone;

  SosContact({required this.name, required this.phone});
}

class SosNotifier extends StateNotifier<List<SosContact>> {
  SosNotifier()
      : super([
          SosContact(name: 'Mom', phone: '+91 98765 43210'),
          SosContact(name: 'Brother', phone: '+91 87654 32109'),
        ]);

  void addContact(SosContact contact) {
    state = [...state, contact];
  }

  void removeContact(String phone) {
    state = state.where((c) => c.phone != phone).toList();
  }

  Future<void> triggerEmergency(String userId) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final supabase = Supabase.instance.client;

      // Fetch user profile details
      final userResponse = await supabase.from('profiles').select().eq('id', userId).maybeSingle();
      final customerName = userResponse?['name'] ?? 'Unknown User';
      final customerPhone = userResponse?['phone'] ?? 'N/A';
      final customerEmail = userResponse?['email'] ?? 'N/A';

      final message = 'SOS EMERGENCY: Roadside Help needed for $customerName. Contact: $customerPhone. Email: $customerEmail. Coordinates: [${position.latitude}, ${position.longitude}]';

      // Log to Supabase for Admin Dashboard
      final alertData = {
        'user_id': userId,
        'message': message,
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
          'customer_name': customerName,
          'customer_phone': customerPhone,
          'customer_email': customerEmail,
        },
        'contacts_notified':
            state.map((c) => '${c.name} (${c.phone})').toList(),
        'status': 'pending',
        'created_at': DateTime.now().utcIso,
      };

      await supabase.from('emergency_alerts').insert(alertData);

      // Broadcast to Nearby Service Team (Technicians)
      await supabase.from('technician_emergency_broadcast').insert({
        ...alertData,
        'type': 'ROADSIDE_EMERGENCY',
        'is_acknowledged': false,
      });

      // Notify Help Desk Manager (All Admins / Management users)
      final List<dynamic> managersResponse = await supabase
          .from('profiles')
          .select('id')
          .or('role.eq.admin,role.eq.management');

      for (final m in managersResponse) {
        final managerId = m['id'].toString();
        await supabase.from('user_notifications').insert({
          'user_id': managerId,
          'title': '🚨 ROADSIDE EMERGENCY SOS',
          'description': 'Customer $customerName ($customerPhone) triggered SOS. Location: Lat ${position.latitude}, Lng ${position.longitude}',
          'type': 'EMERGENCY_ALERT',
          'is_read': false,
          'created_at': DateTime.now().utcIso,
        });
      }

      // Notify Emergency Contacts via SMS Intent
      if (state.isNotEmpty) {
        final googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
        final message =
            'EMERGENCY ALERT: I am in trouble! My live location: $googleMapsUrl';

        // Android/iOS SMS scheme
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: state.map((c) => c.phone).join(','),
          queryParameters: <String, String>{
            'body': message,
          },
        );

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        }
      }
    } catch (e) {
      // Log to Crashlytics or handle error
    }
  }
}

final sosProvider = StateNotifierProvider<SosNotifier, List<SosContact>>((ref) {
  return SosNotifier();
});
