/// Domain Entity: Lounge Staff Member
/// Represents a staff member working at a lounge
class LoungeStaff {
  final String id;
  final String userId;
  final String loungeId;
  final String fullName;
  final String nicNumber;
  final String? email;
  final String? phone;
  final bool profileCompleted;
  final String approvalStatus; // approved, pending, declined
  final String employmentStatus; // active, suspended, terminated
  final DateTime? hiredDate;
  final DateTime? terminatedDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoungeStaff({
    required this.id,
    required this.userId,
    required this.loungeId,
    required this.fullName,
    required this.nicNumber,
    this.email,
    this.phone,
    required this.profileCompleted,
    required this.approvalStatus,
    required this.employmentStatus,
    this.hiredDate,
    this.terminatedDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';
  bool get isDeclined => approvalStatus == 'declined';
  bool get isActive => employmentStatus == 'active';
  bool get isSuspended => employmentStatus == 'suspended';
  bool get isTerminated => employmentStatus == 'terminated';
}
