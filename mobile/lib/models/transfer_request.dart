class TransferRequest {
  final String senderEmail;
  final String receiverEmail;
  final int amount;

  TransferRequest({
    required this.senderEmail,
    required this.receiverEmail,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'senderEmail': senderEmail,
    'receiverEmail': receiverEmail,
    'amount': amount,
  };
}