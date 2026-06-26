import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/wallet_service.dart';
import '../../services/transfer_service.dart';
import '../../storage/token_storage.dart';
import '../../models/transaction.dart';
import '../../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _balance;
  String? _email;
  String? _userId;
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;
  bool _isBalanceVisible = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final email = await TokenStorage.getEmail();
      final userId = await TokenStorage.getUserId();
      final balance = await WalletService.getBalance();
      final history = await TransferService.getHistory();
      
      setState(() {
        _email = email;
        _userId = userId;
        _balance = balance;
        _recentTransactions = history.take(5).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      body: SafeArea(
        child: _isLoading
            ? const LoadingWidget()
            : RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF6C63FF),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFF1D1F2E),
                                  child: Text(
                                    (_email?.isNotEmpty == true) ? _email![0].toUpperCase() : 'U',
                                    style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: const Color(0xFF7E8494).withOpacity(0.8),
                                      ),
                                    ),
                                    Text(
                                      _email?.split('@')[0] ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D1F2E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Balance Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF928DFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Balance',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                                    child: Icon(
                                      _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _error != null
                                  ? Text(_error!, style: const TextStyle(color: Colors.white))
                                  : Text(
                                      _isBalanceVisible ? '${_balance ?? 0} FCFA' : '•••••• FCFA',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ID: ${_userId?.substring(0, 8) ?? '...'}-MT',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Quick Actions Section
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.send_rounded,
                                label: 'Send',
                                color: const Color(0xFF6C63FF),
                                onTap: () async {
                                  await Navigator.pushNamed(context, '/transfer');
                                  _loadData();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.add_rounded,
                                label: 'Top Up',
                                color: const Color(0xFF00C853),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.history_rounded,
                                label: 'History',
                                color: const Color(0xFFFFAB00),
                                onTap: () => Navigator.pushNamed(context, '/history'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Recent Transactions Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/history'),
                              child: const Text(
                                'See All',
                                style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (_recentTransactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              'No recent transactions',
                              style: TextStyle(color: Color(0xFF7E8494)),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _recentTransactions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tx = _recentTransactions[index];
                            final isSent = tx.senderId == _userId;
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141522),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSent 
                                          ? const Color(0xFFFF5252).withOpacity(0.1)
                                          : const Color(0xFF00C853).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSent ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
                                      color: isSent ? const Color(0xFFFF5252) : const Color(0xFF00C853),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isSent ? 'Sent to ${tx.receiverId.substring(0, 8)}' : 'Received from ${tx.senderId.substring(0, 8)}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(tx.createdAt),
                                          style: TextStyle(color: const Color(0xFF7E8494).withOpacity(0.8), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isSent ? '-' : '+'}${tx.amount} FCFA',
                                    style: TextStyle(
                                      color: isSent ? const Color(0xFFFF5252) : const Color(0xFF00C853),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF141522),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
