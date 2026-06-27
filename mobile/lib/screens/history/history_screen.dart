import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../services/transfer_service.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
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

  final Map<String, Map<String, String>> _localizedText = {
    'en': {
      'title': 'Transaction History',
      'sent_to': 'Sent to',
      'received_from': 'Received from',
      'empty_title': 'No transactions yet',
      'empty_subtitle': 'Your transaction history will appear here',
      'try_again': 'Try Again',
    },
    'fr': {
      'title': 'Historique',
      'sent_to': 'Envoyé à',
      'received_from': 'Reçu de',
      'empty_title': 'Aucune transaction',
      'empty_subtitle': 'Votre historique de transactions s\'affichera ici',
      'try_again': 'Réessayer',
    }
  };

  String _get(String key, String langCode) {
    return _localizedText[langCode]![key]!;
  }

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

  String _formatDate(String dateStr, String langCode) {
    try {
      final date = DateTime.parse(dateStr);
      final monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthsFr = ['Janv', 'Févr', 'Mars', 'Avril', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'];
      final month = langCode == 'fr' ? monthsFr[date.month - 1] : monthsEn[date.month - 1];
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, child) {
        final lang = locale.languageCode;
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Custom Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1D1F2E) : const Color(0xFFF0F1F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface, size: 20),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                _get('title', lang),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => ThemeService.toggleTheme(),
                            icon: Icon(
                              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              color: theme.primaryColor,
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
                          ? _buildErrorState(lang)
                          : _transactions == null || _transactions!.isEmpty
                              ? _buildEmptyState(lang)
                              : RefreshIndicator(
                                  onRefresh: _loadHistory,
                                  color: theme.primaryColor,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(24),
                                    itemCount: _transactions!.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final tx = _transactions![index];
                                      final isSent = tx.senderId == _currentUserId;
                                      return _buildTransactionItem(tx, isSent, lang);
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction tx, bool isSent, String langCode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1),
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
                  isSent 
                    ? '${_get('sent_to', langCode)} ${tx.receiverId.substring(0, 8)}...' 
                    : '${_get('received_from', langCode)} ${tx.senderId.substring(0, 8)}...',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(tx.createdAt, langCode),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
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

  Widget _buildEmptyState(String langCode) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, color: theme.colorScheme.onSurface.withOpacity(0.2), size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            _get('empty_title', langCode),
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _get('empty_subtitle', langCode),
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String langCode) {
    final theme = Theme.of(context);
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
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _loadHistory,
              child: Text(_get('try_again', langCode), style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
