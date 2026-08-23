import 'package:flutter/material.dart';

enum PolicyStatus {
  active,
  expiringSoon,
  expired,
}

class InsurancePlan {
  final String id;
  final String title;
  final String subtitle;
  final double basePrice;
  final String frequency;
  final Color color;
  final String emoji;
  final String tag;
  final List<String> benefits;
  final double idvPercentage;

  const InsurancePlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.basePrice,
    this.frequency = 'yr',
    required this.color,
    required this.emoji,
    this.tag = '',
    required this.benefits,
    required this.idvPercentage,
  });
}

class InsuranceAddOn {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final IconData icon;

  const InsuranceAddOn({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
  });
}

class InsurancePolicy {
  final String id;
  final String policyNumber;
  final String vehicleName;
  final String vehiclePlate;
  final String vehicleType;
  final String planTitle;
  final String planId;
  final String provider;
  final DateTime issueDate;
  final DateTime expiryDate;
  final double totalPremium;
  final double idvAmount;
  final String ownerName;
  final String ownerPhone;
  final String nomineeName;
  final String nomineeRelation;
  final List<String> selectedAddOns;
  final PolicyStatus status;

  const InsurancePolicy({
    required this.id,
    required this.policyNumber,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.vehicleType,
    required this.planTitle,
    required this.planId,
    this.provider = 'RoadRobos Shield Cover (Powered by Acko)',
    required this.issueDate,
    required this.expiryDate,
    required this.totalPremium,
    required this.idvAmount,
    required this.ownerName,
    required this.ownerPhone,
    required this.nomineeName,
    required this.nomineeRelation,
    this.selectedAddOns = const [],
    this.status = PolicyStatus.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'policyNumber': policyNumber,
      'vehicleName': vehicleName,
      'vehiclePlate': vehiclePlate,
      'vehicleType': vehicleType,
      'planTitle': planTitle,
      'planId': planId,
      'provider': provider,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'totalPremium': totalPremium,
      'idvAmount': idvAmount,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'nomineeName': nomineeName,
      'nomineeRelation': nomineeRelation,
      'selectedAddOns': selectedAddOns,
      'status': status.name,
    };
  }

  factory InsurancePolicy.fromMap(Map<String, dynamic> map) {
    return InsurancePolicy(
      id: map['id'] ?? '',
      policyNumber: map['policyNumber'] ?? '',
      vehicleName: map['vehicleName'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      vehicleType: map['vehicleType'] ?? 'Bike',
      planTitle: map['planTitle'] ?? '',
      planId: map['planId'] ?? '',
      provider: map['provider'] ?? 'RoadRobos Shield',
      issueDate: DateTime.tryParse(map['issueDate'] ?? '') ?? DateTime.now(),
      expiryDate: DateTime.tryParse(map['expiryDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 365)),
      totalPremium: (map['totalPremium'] ?? 0.0).toDouble(),
      idvAmount: (map['idvAmount'] ?? 0.0).toDouble(),
      ownerName: map['ownerName'] ?? '',
      ownerPhone: map['ownerPhone'] ?? '',
      nomineeName: map['nomineeName'] ?? '',
      nomineeRelation: map['nomineeRelation'] ?? '',
      selectedAddOns: List<String>.from(map['selectedAddOns'] ?? []),
      status: PolicyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PolicyStatus.active,
      ),
    );
  }
}
