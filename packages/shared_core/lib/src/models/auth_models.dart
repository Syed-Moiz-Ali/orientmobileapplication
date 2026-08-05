class TokenResponse {
  final String role;
  final String token;
  final String? refreshToken;
  const TokenResponse({this.role = '', this.token = '', this.refreshToken});
  factory TokenResponse.fromJson(Map<String, dynamic> j) => TokenResponse(
    role: j['role'] as String? ?? '',
    token: j['token'] as String? ?? '',
    refreshToken: j['refreshToken'] as String?,
  );
}

/// Unified session/profile payload from GET /auth/me.
class MeResponse {
  final int? userId;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isActive;
  final int? branchId;
  final String branchName;

  final int? staffId;
  final String empId;
  final String avatarInitials;
  final String shift;
  final String designation;
  final String department;

  final int? customerId;
  final String memberId;

  const MeResponse({
    this.userId,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.role = '',
    this.isActive = true,
    this.branchId,
    this.branchName = '',
    this.staffId,
    this.empId = '',
    this.avatarInitials = '',
    this.shift = '',
    this.designation = '',
    this.department = '',
    this.customerId,
    this.memberId = '',
  });

  factory MeResponse.fromJson(Map<String, dynamic> j) => MeResponse(
    userId: (j['userId'] as num?)?.toInt(),
    name: j['name'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    email: j['email'] as String? ?? '',
    role: j['role'] as String? ?? '',
    isActive: j['isActive'] as bool? ?? true,
    branchId: (j['branchId'] as num?)?.toInt(),
    branchName: j['branchName'] as String? ?? '',
    staffId: (j['staffId'] as num?)?.toInt(),
    empId: j['empId'] as String? ?? '',
    avatarInitials: j['avatarInitials'] as String? ?? '',
    shift: j['shift'] as String? ?? '',
    designation: j['designation'] as String? ?? '',
    department: j['department'] as String? ?? '',
    customerId: (j['customerId'] as num?)?.toInt(),
    memberId: j['memberId'] as String? ?? '',
  );

  String get initials =>
      avatarInitials.isNotEmpty ? avatarInitials : _computeInitials(name);

  String _computeInitials(String n) {
    if (n.isEmpty) return 'U';
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
