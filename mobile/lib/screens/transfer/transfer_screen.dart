import 'package:flutter/material.dart';
import '../../models/transfer_request.dart';
import '../../services/transfer_service.dart';
import '../../storage/token_storage.dart';
import '../../widgets/custom_button.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String _amount = "0";
  bool _isLoading = false;
  String? _error;

  // For UI consistency with the image, we'll assume a recipient is already selected
  final String _recipientName = "Alice Martin";
  final String _recipientEmail = "alice@example.com";

  void _onKeyTap(String key) {
    setState(() {
      if (key == "⌫") {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = "0";
        }
      } else {
        if (_amount == "0") {
          _amount = key;
        } else {
          if (_amount.length < 9) {
            _amount += key;
          }
        }
      }
    });
  }

  void _addAmount(int value) {
    setState(() {
      int current = int.tryParse(_amount.replaceAll(',', '')) ?? 0;
      _amount = (current + value).toString();
    });
  }

  String get _formattedAmount {
    if (_amount == "0") return "0";
    try {
      final value = int.parse(_amount.replaceAll(',', ''));
      return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},'
      );
    } catch (e) {
      return _amount;
    }
  }

  Future<void> _transfer() async {
    int amount = int.tryParse(_amount.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      setState(() => _error = "Please enter a valid amount");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final senderEmail = await TokenStorage.getEmail();
      if (senderEmail == null) throw Exception('Not logged in');

      await TransferService.transfer(TransferRequest(
        senderEmail: senderEmail,
        receiverEmail: _recipientEmail,
        amount: amount,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer successful! ✅')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Section: Header and Amount
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                          decoration: const BoxDecoration(
                            color: Color(0xFF141522),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1D1F2E),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Text(
                                    'Send Money',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Recipient Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D1F2E).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF252836), width: 1),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.8),
                                      child: Text(
                                        _recipientName.substring(0, 2).toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _recipientName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _recipientEmail,
                                            style: TextStyle(
                                              color: const Color(0xFF7E8494).withValues(alpha: 0.8),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: const Color(0xFF7E8494).withValues(alpha: 0.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Amount Display
                        Column(
                          children: [
                            Text(
                              _formattedAmount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'FCFA',
                              style: TextStyle(
                                color: Color(0xFF7E8494),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom Section: Quick buttons, Keypad and Transfer Button
                    Column(
                      children: [
                        // Quick Amount Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _quickButton("+500", () => _addAmount(500)),
                              const SizedBox(width: 12),
                              _quickButton("+1000", () => _addAmount(1000)),
                              const SizedBox(width: 12),
                              _quickButton("Max", () {}),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Keypad
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _keypadButton("1"),
                                  const SizedBox(width: 12),
                                  _keypadButton("2"),
                                  const SizedBox(width: 12),
                                  _keypadButton("3"),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _keypadButton("4"),
                                  const SizedBox(width: 12),
                                  _keypadButton("5"),
                                  const SizedBox(width: 12),
                                  _keypadButton("6"),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _keypadButton("7"),
                                  const SizedBox(width: 12),
                                  _keypadButton("8"),
                                  const SizedBox(width: 12),
                                  _keypadButton("9"),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _keypadButton(","),
                                  const SizedBox(width: 12),
                                  _keypadButton("0"),
                                  const SizedBox(width: 12),
                                  _keypadButton("⌫"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: CustomButton(
                            label: 'Transfer',
                            onPressed: _transfer,
                            isLoading: _isLoading,
                            gradient: const [
                              Color(0xFF6C63FF),
                              Color(0xFF928DFF),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _quickButton(String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1F2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF252836), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypadButton(String label) {
    return Expanded(
      child: InkWell(
        onTap: () => _onKeyTap(label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF1D1F2E),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
