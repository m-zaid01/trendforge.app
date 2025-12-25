class UserPreferences {
  final List<String> interests;
  final String role;

  UserPreferences({
    required this.interests,
    required this.role,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      interests: List<String>.from(json['interests'] ?? []),
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interests': interests,
      'role': role,
    };
  }
}
