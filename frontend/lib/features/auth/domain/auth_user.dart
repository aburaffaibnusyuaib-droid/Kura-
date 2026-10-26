import 'package:supabase_flutter/supabase_flutter.dart';

/// Domain model representasi pengguna autentikasi terpadu Kura AI.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.isAnonymous = false,
    this.rawUser,
  });

  final String id;
  final String email;
  final String fullName;
  final bool isAnonymous;
  final User? rawUser;

  factory AuthUser.fromSupabase(User user, {String? fullName}) {
    final metaName = user.userMetadata?['full_name'] as String?;
    final resolvedName = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : (metaName != null && metaName.trim().isNotEmpty
            ? metaName.trim()
            : (user.email != null && user.email!.contains('@')
                ? user.email!.split('@').first
                : 'Pengguna Kura'));

    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      fullName: resolvedName,
      isAnonymous: user.isAnonymous,
      rawUser: user,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'isAnonymous': isAnonymous,
      };
}
