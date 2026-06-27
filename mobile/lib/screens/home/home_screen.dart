import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/wallet_service.dart';
import '../../services/transfer_service.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
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

  final Map<String, Map<String, String>> _localizedText = {
    'en': {
      'welcome': 'Welcome back,',
      'total_balance': 'Total Balance',
      'quick_actions': 'Quick Actions',
      'send': 'Send',
      'topup': 'Top Up',
      'history': 'History',
      'recent': 'Recent Transactions',
      'see_all': 'See All',
      'no_recent': 'No recent transactions',
      'sent_to': 'Sent to',
      'received_from': 'Received from',
    },
    'fr': {
      'welcome': 'Bon retour,',
      'total_balance': 'Solde Total',
      'quick_actions': 'Actions Rapides',
      'send': 'Envoyer',
      'topup': 'Recharger',
      'history': 'Historique',
      'recent': 'Transactions Récentes',
      'see_all': 'Voir Tout',
      'no_recent': 'Aucune transaction récente',
      'sent_to': 'Envoyé à',
      'received_from': 'Reçu de',
    }
  };

  String _get(String key, String langCode) {
    return _localizedText[langCode]![key]!;
  }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, child) {
        final lang = locale.languageCode;
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: _isLoading
                ? const LoadingWidget()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: theme.primaryColor,
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
                                      backgroundColor: theme.colorScheme.surface,
                                      child: Text(
                                        (_email?.isNotEmpty == true) ? _email![0].toUpperCase() : 'U',
                                        style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _get('welcome', lang),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                        Text(
                                          _email?.split('@')[0] ?? 'User',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => ThemeService.toggleTheme(),
                                      icon: Icon(
                                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        onPressed: _logout,
                                        icon: Icon(Icons.logout_rounded, color: theme.colorScheme.onSurface, size: 22),
                                      ),
                                    ),
                                  ],
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
                                      Text(
                                        _get('total_balance', lang),
                                        style: const TextStyle(
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _get('quick_actions', lang),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
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
                                    label: _get('send', lang),
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
                                    label: _get('topup', lang),
                                    color: const Color(0xFF00C853),
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _ActionCard(
                                    icon: Icons.history_rounded,
                                    label: _get('history', lang),
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
                                Text(
                                  _get('recent', lang),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/history'),
                                  child: Text(
                                    _get('see_all', lang),
                                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (_recentTransactions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(40),
                              child: Center(
                                child: Text(
                                  _get('no_recent', lang),
                                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
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
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      if (!isDark)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
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
                                              isSent 
                                                ? '${_get('sent_to', lang)} ${tx.receiverId.substring(0, 8)}' 
                                                : '${_get('received_from', lang)} ${tx.senderId.substring(0, 8)}',
                                              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(tx.createdAt),
                                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
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
      },
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
