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
  }) : avatarInitials =
           avatarInitials ??
           name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join();
}
