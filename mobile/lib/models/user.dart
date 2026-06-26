
class User {
  final String email;
  final int balance;

  User({required this.email, required this.balance});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      balance: json['balance'],
    );
  }
}