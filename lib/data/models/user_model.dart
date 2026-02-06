import '../../domain/entities/user.dart';

/// Data Model: User
/// This handles JSON serialization/deserialization
/// Maps between API format and domain entity
class UserModel extends User {
  UserModel({
    required super.id,
    required super.phoneNumber,
    super.email,
    super.firstName,
    super.lastName,
    super.nic,
    required super.roles,
    required super.profileCompleted,
    required super.phoneVerified,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      phoneNumber:
          json['phone'] as String? ?? json['phone_number'] as String? ?? '',
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      nic: json['nic'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      profileCompleted: json['profile_completed'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phoneNumber,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'nic': nic,
      'roles': roles,
      'profile_completed': profileCompleted,
      'phone_verified': phoneVerified,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      phoneNumber: phoneNumber,
      email: email,
      firstName: firstName,
      lastName: lastName,
      nic: nic,
      roles: roles,
      profileCompleted: profileCompleted,
      phoneVerified: phoneVerified,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phoneNumber: user.phoneNumber,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      nic: user.nic,
      roles: user.roles,
      profileCompleted: user.profileCompleted,
      phoneVerified: user.phoneVerified,
      status: user.status,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
