import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class IconHelper {
  static IconData getIcon(String name) {
    switch (name.toLowerCase()) {
      case 'routing':
        return Iconsax.routing;
      case 'car':
        return Iconsax.car;
      case 'build':
        return Icons.build_rounded;
      case 'safe_home':
        return Iconsax.safe_home;
      case 'wallet':
        return Iconsax.wallet_3;
      case 'notification':
        return Iconsax.notification;
      case 'star':
        return Iconsax.star;
      case 'location':
        return Iconsax.location;
      case 'car_rental':
        return Icons.car_rental_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'local_car_wash':
        return Icons.local_car_wash_rounded;
      case 'local_shipping':
        return Icons.local_shipping_rounded;
      case 'oil_barrel':
        return Icons.oil_barrel_rounded;
      case 'ac_unit':
        return Icons.ac_unit_rounded;
      case 'tire_repair':
        return Icons.tire_repair_rounded;
      case 'electrical_services':
        return Icons.electrical_services_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static Color getColor(String hexColor) {
    if (hexColor.isEmpty) return Colors.black;
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.substring(1);
    }
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
