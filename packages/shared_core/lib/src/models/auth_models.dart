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
