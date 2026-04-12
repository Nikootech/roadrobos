import 'package:latlong2/latlong.dart';

enum DriverApprovalStatus { none, pending, approved, rejected }
enum DriverTripStatus { none, enroutePickup, arrived, otpVerify, started, completed }

class DriverModel {
  final String id;
  final bool isOnline;
  final double todayEarnings;
  final double weeklyEarnings;
  final int totalRides;
  final int weeklyRides;
  final String acceptanceRate;
  final String onlineTime;
  final DriverApprovalStatus approvalStatus;
  final LatLng? currentPosition;
  final String? fcmToken;
  final String vehicleModel;
  final String vehiclePlate;

  DriverModel({
    required this.id,
    this.isOnline = false,
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.totalRides = 0,
    this.weeklyRides = 0,
    this.acceptanceRate = '100%',
    this.onlineTime = '0h 0m',
    this.approvalStatus = DriverApprovalStatus.none,
    this.currentPosition,
    this.fcmToken,
    this.vehicleModel = '',
    this.vehiclePlate = '',
  });

  factory DriverModel.fromMap(Map<String, dynamic> map, String id) {
    return DriverModel(
      id: id,
      isOnline: map['isOnline'] ?? false,
      todayEarnings: (map['todayEarnings'] ?? 0.0).toDouble(),
      weeklyEarnings: (map['weeklyEarnings'] ?? 0.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      weeklyRides: map['weeklyRides'] ?? 0,
      acceptanceRate: map['acceptanceRate'] ?? '100%',
      onlineTime: map['onlineTime'] ?? '0h 0m',
      approvalStatus: DriverApprovalStatus.values.firstWhere(
        (e) => e.toString() == 'DriverApprovalStatus.${map['approvalStatus']}',
        orElse: () => DriverApprovalStatus.none,
      ),
      currentPosition: map['lat'] != null && map['lng'] != null 
          ? LatLng(map['lat'], map['lng']) 
          : null,
      fcmToken: map['fcmToken'],
      vehicleModel: map['vehicleModel'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isOnline': isOnline,
      'todayEarnings': todayEarnings,
      'weeklyEarnings': weeklyEarnings,
      'totalRides': totalRides,
      'weeklyRides': weeklyRides,
      'acceptanceRate': acceptanceRate,
      'onlineTime': onlineTime,
      'approvalStatus': approvalStatus.toString().split('.').last,
      'lat': currentPosition?.latitude,
      'lng': currentPosition?.longitude,
      'fcmToken': fcmToken,
      'vehicleModel': vehicleModel,
      'vehiclePlate': vehiclePlate,
    };
  }

  DriverModel copyWith({
    bool? isOnline,
    double? todayEarnings,
    double? weeklyEarnings,
    int? totalRides,
    int? weeklyRides,
    String? acceptanceRate,
    String? onlineTime,
    DriverApprovalStatus? approvalStatus,
    LatLng? currentPosition,
    String? fcmToken,
    String? vehicleModel,
    String? vehiclePlate,
  }) {
    return DriverModel(
      id: id,
      isOnline: isOnline ?? this.isOnline,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      totalRides: totalRides ?? this.totalRides,
      weeklyRides: weeklyRides ?? this.weeklyRides,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      onlineTime: onlineTime ?? this.onlineTime,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      fcmToken: fcmToken ?? this.fcmToken,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    );
  }
}
