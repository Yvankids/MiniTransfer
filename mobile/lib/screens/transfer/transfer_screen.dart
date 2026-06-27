import 'package:flutter/material.dart';
import '../../models/transfer_request.dart';
import '../../models/user.dart';
import '../../services/transfer_service.dart';
import '../../services/user_service.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
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

  User? _selectedUser;

  final Map<String, Map<String, String>> _localizedText = {
    'en': {
      'send_money': 'Send Money',
      'select_recipient': 'Select Recipient',
      'tap_to_search': 'Tap to search or enter email',
      'recipient_needed': 'Please select a recipient',
      'amount_needed': 'Please enter a valid amount',
      'transfer_success': 'Transfer successful! ✅',
      'transfer_btn': 'Transfer',
    },
    'fr': {
      'send_money': 'Envoyer de l\'argent',
      'select_recipient': 'Choisir un destinataire',
      'tap_to_search': 'Appuyez pour rechercher ou saisir un email',
      'recipient_needed': 'Veuillez sélectionner un destinataire',
      'amount_needed': 'Veuillez saisir un montant valide',
      'transfer_success': 'Transfert réussi ! ✅',
      'transfer_btn': 'Transférer',
    }
  };

  String _get(String key, String langCode) {
    return _localizedText[langCode]![key]!;
  }

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

  Future<void> _showUserSearch(String lang) async {
    final theme = Theme.of(context);
    final user = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => _UserSearchSheet(langCode: lang),
    );

    if (user != null) {
      setState(() {
        _selectedUser = user;
      });
    }
  }

  Future<void> _transfer(String lang) async {
    if (_selectedUser == null) {
      setState(() => _error = _get('recipient_needed', lang));
      return;
    }

    int amount = int.tryParse(_amount.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      setState(() => _error = _get('amount_needed', lang));
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
        receiverEmail: _selectedUser!.email,
        amount: amount,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_get('transfer_success', lang))),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, child) {
        final lang = locale.languageCode;
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
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
                                            _get('send_money', lang),
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
                                  const SizedBox(height: 32),
                                  InkWell(
                                    onTap: () => _showUserSearch(lang),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDark ? theme.colorScheme.surface.withOpacity(0.5) : const Color(0xFFF8F9FE),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: theme.primaryColor.withOpacity(0.8),
                                            child: Text(
                                              _selectedUser != null 
                                                ? _selectedUser!.email.substring(0, 2).toUpperCase()
                                                : "?",
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _selectedUser != null 
                                                    ? (_selectedUser!.email.contains('@') ? _selectedUser!.email.split('@')[0] : _selectedUser!.email) 
                                                    : _get('select_recipient', lang),
                                                  style: TextStyle(
                                                    color: theme.colorScheme.onSurface,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _selectedUser?.email ?? _get('tap_to_search', lang),
                                                  style: TextStyle(
                                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                            Column(
                              children: [
                                Text(
                                  _formattedAmount,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'FCFA',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Column(
                          children: [
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
                                label: _get('transfer_btn', lang),
                                onPressed: () => _transfer(lang),
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
      },
    );
  }

  Widget _quickButton(String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypadButton(String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () => _onKeyTap(label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserSearchSheet extends StatefulWidget {
  final String langCode;
  const _UserSearchSheet({required this.langCode});

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final _searchController = TextEditingController();
  List<User> _results = [];
  bool _isSearching = false;

  final Map<String, Map<String, String>> _localized = {
    'en': {
      'title': 'Search Recipient',
      'hint': 'Enter email...',
      'use': 'Use',
      'manual': 'Directly enter this email',
    },
    'fr': {
      'title': 'Rechercher un destinataire',
      'hint': 'Saisir un email...',
      'use': 'Utiliser',
      'manual': 'Saisir cet email directement',
    }
  };

  String _get(String key) => _localized[widget.langCode]![key]!;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final users = await UserService.searchUsers(query);
      setState(() => _results = users);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isSearching = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim();
    final showManualEntry = query.isNotEmpty && _isValidEmail(query) && !_results.any((u) => u.email.toLowerCase() == query.toLowerCase());

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Text(
            _get('title'),
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: _get('hint'),
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
              prefixIcon: Icon(Icons.search, color: theme.primaryColor),
              filled: true,
              fillColor: theme.brightness == Brightness.dark ? const Color(0xFF1D1F2E) : const Color(0xFFF0F1F7),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            onChanged: (val) {
              setState(() {});
              _performSearch(val.trim());
            },
          ),
          const SizedBox(height: 24),
          if (showManualEntry)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF1D1F2E) : const Color(0xFFF0F1F7),
                child: Icon(Icons.person_add_alt_1, color: theme.primaryColor),
              ),
              title: Text("${_get('use')} '$query'", style: TextStyle(color: theme.colorScheme.onSurface)),
              subtitle: Text(_get('manual'), style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
              onTap: () => Navigator.pop(context, User(email: query, balance: 0)),
            ),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final user = _results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor.withOpacity(0.2),
                          child: Text(user.email[0].toUpperCase(), style: TextStyle(color: theme.primaryColor)),
                        ),
                        title: Text(user.email, style: TextStyle(color: theme.colorScheme.onSurface)),
                        onTap: () => Navigator.pop(context, user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
