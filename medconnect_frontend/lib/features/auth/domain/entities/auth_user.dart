class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    this.profile,
  });

  final String id;
  final String email;
  final String role;

  final Map<String, dynamic>? profile;
  
}
