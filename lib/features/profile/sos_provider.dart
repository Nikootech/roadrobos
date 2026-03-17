import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final sosProvider = StateNotifierProvider<SosNotifier, List<SosContact>>((ref) {
  return SosNotifier();
});
