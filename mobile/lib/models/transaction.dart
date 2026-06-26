class Transaction {
  final String id;
  final String senderId;
  final String receiverId;
  final int amount;
  final String status;
  final String createdAt;

  Transaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      amount: json['amount'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}