import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class SosContact {
  final String name;
  final String phone;

  SosContact({required this.name, required this.phone});
}

class SosNotifier extends StateNotifier<List<SosContact>> {
  SosNotifier() : super([
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
      
      // Log to Firestore for Admin Dashboard
      final alertData = {
        'userId': userId,
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'contactsNotified': state.map((c) => '${c.name} (${c.phone})').toList(),
        'status': 'pending',
      };

      await FirebaseFirestore.instance.collection('emergency_alerts').add(alertData);

      // Broadcast to Nearby Service Team (Technicians)
      await FirebaseFirestore.instance.collection('technician_emergency_broadcast').add({
        ...alertData,
        'type': 'ROADSIDE_EMERGENCY',
        'isAcknowledge': false,
      });

      // Notify Emergency Contacts via SMS Intent
      if (state.isNotEmpty) {
        final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
        final message = 'EMERGENCY ALERT: I am in trouble! My live location: $googleMapsUrl';
        
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
