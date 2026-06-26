import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../services/transfer_service.dart';
import '../../storage/token_storage.dart';
import '../../widgets/loading_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction>? _transactions;
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userId = await TokenStorage.getUserId();
      final transactions = await TransferService.getHistory();
      setState(() {
        _transactions = transactions;
        _currentUserId = userId;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[date.month - 1];
      final day = date.day.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$month $day, ${date.year} • $hour:$minute';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
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
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingWidget())
                  : _error != null
                      ? _buildErrorState()
                      : _transactions == null || _transactions!.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadHistory,
                              color: const Color(0xFF6C63FF),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(24),
                                itemCount: _transactions!.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final tx = _transactions![index];
                                  final isSent = tx.senderId == _currentUserId;
                                  return _buildTransactionItem(tx, isSent);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx, bool isSent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141522),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1D1F2E), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSent 
                  ? const Color(0xFFFF5252).withOpacity(0.1)
                  : const Color(0xFF00C853).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSent ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
              color: isSent ? const Color(0xFFFF5252) : const Color(0xFF00C853),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSent ? 'Sent to ${tx.receiverId.substring(0, 8)}...' : 'Received from ${tx.senderId.substring(0, 8)}...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(tx.createdAt),
                  style: TextStyle(
                    color: const Color(0xFF7E8494).withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isSent ? '-' : '+'}${tx.amount}',
                style: TextStyle(
                  color: isSent ? const Color(0xFFFF5252) : const Color(0xFF00C853),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'FCFA',
                style: TextStyle(
                  color: const Color(0xFF7E8494).withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF141522),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, color: const Color(0xFF7E8494).withOpacity(0.3), size: 64),
          ),
          const SizedBox(height: 24),
          const Text(
            'No transactions yet',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(color: const Color(0xFF7E8494).withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFFF5252), size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _loadHistory,
              child: const Text('Try Again', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
