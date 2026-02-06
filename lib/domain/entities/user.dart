/// Domain Entity: User
/// This represents the business model independent of any data source
class User {
  final String id;
  final String phoneNumber;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? nic;
  final List<String> roles;
  final bool profileCompleted;
  final bool phoneVerified;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.phoneNumber,
    this.email,
    this.firstName,
    this.lastName,
    this.nic,
    required this.roles,
    required this.profileCompleted,
    required this.phoneVerified,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Business logic: Check if user is a new user
  bool get isNewUser => firstName == null || lastName == null;

  /// Business logic: Get full name
  String get name {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return phoneNumber;
  }

  /// Business logic: Check if user has specific role
  bool hasRole(String role) => roles.contains(role);

  /// Business logic: Check if user is passenger
  bool get isPassenger => hasRole('passenger');

  /// Business logic: Check if user is driver
  bool get isDriver => hasRole('driver');

  /// Business logic: Check if user is conductor
  bool get isConductor => hasRole('conductor');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $name, roles: $roles)';
}
