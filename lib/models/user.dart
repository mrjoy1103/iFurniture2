class User {
  final String username;
  final String email;
  final String token;
  final String user;
  final bool isActive;
  final String salesman;

  User({
    required this.username,
    required this.email,
    required this.token,
    required this.user,
    required this.isActive,
    required this.salesman,
  });

  // Method to convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['UserNames'] ?? '', // Provide a default value if null
      email: json['Email'] ?? '', // Provide a default value if null
      token: json['Token'] ?? '', // Provide a default value if null
      user: json['User'] ?? '', // Provide a default value if null
      isActive: json['IsActive'] ?? false, // Provide a default value if null
      salesman: json['Salesman'] ?? '', // Provide a default value if null
    );
  }

  // Method to convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'UserNames': username,
      'Email': email,
      'Token': token,
      'User': user,
      'IsActive': isActive,
      'Salesman': salesman,
    };
  }
}
