class ProfileData {
  final String name;
  final String id;
  final String role;
  final String branch;
  final String shift;
  final String email;
  final String phone;
  final String avatarInitials;
  final int totalJobs;
  final int completedJobs;
  final int pendingJobs;

  ProfileData({
    required this.name,
    required this.id,
    required this.role,
    required this.branch,
    this.shift = '',
    this.email = '',
    this.phone = '',
    String? avatarInitials,
    this.totalJobs = 0,
    this.completedJobs = 0,
    this.pendingJobs = 0,
  }) : avatarInitials = avatarInitials ?? _initials(name);
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return 'S';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
