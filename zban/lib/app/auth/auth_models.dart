class AuthUser {
  final String id;
  final String fullName;
  final String email;
  final String theme;
  final String? ageRange;
  final String? gender;
  final bool hasLoan;
  final bool hasSavings;
  final String? profileImageBase64;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.theme,
    this.ageRange,
    this.gender,
    required this.hasLoan,
    required this.hasSavings,
    this.profileImageBase64,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '') as String,
      fullName: (json['fullName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      theme: (json['theme'] ?? 'violet') as String,
      ageRange: json['ageRange'] as String?,
      gender: json['gender'] as String?,
      hasLoan: (json['hasLoan'] ?? false) as bool,
      hasSavings: (json['hasSavings'] ?? false) as bool,
      profileImageBase64: json['profileImageBase64'] as String?,
    );
  }
}

class AuthSession {
  final String token;
  final AuthUser user;

  const AuthSession({required this.token, required this.user});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: (json['token'] ?? '') as String,
      user: AuthUser.fromJson((json['user'] ?? const <String, dynamic>{}) as Map<String, dynamic>),
    );
  }
}

