import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for storing admin user data in Firestore
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? countryCode;
  final String? countryDialCode;
  final bool isPhoneVerified;
  final String? photoUrl;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.countryCode,
    this.countryDialCode,
    this.isPhoneVerified = false,
    this.photoUrl,
    this.role = 'admin',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      countryCode: json['countryCode'],
      countryDialCode: json['countryDialCode'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      photoUrl: json['photoUrl'],
      role: json['role'] ?? 'admin',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'countryDialCode': countryDialCode,
      'isPhoneVerified': isPhoneVerified,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? countryDialCode,
    bool? isPhoneVerified,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      countryDialCode: countryDialCode ?? this.countryDialCode,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
