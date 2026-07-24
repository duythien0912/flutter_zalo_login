import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zalo_login/flutter_zalo_login.dart';

void main() => runApp(const MyApp());

const Color kZaloBlue = Color(0xFF0068FF);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Zalo Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kZaloBlue,
        brightness: Brightness.light,
      ),
      home: const MyHomePage(title: 'Flutter Zalo Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ZaloProfileModel? zaloInfo;
  ZaloLoginResult? zaloLoginResult;

  bool _authenticated = false;
  bool _authChecked = false;
  String _hashKey = '';

  // Per-step loading (0 = idle). A single shared flag was wrong — each step
  // shows its own spinner and only that step is busy.
  int _loadingStep = 0;
  bool get _busy => false;

  bool get _inited => _hashKey.isNotEmpty;
  bool get _loggedIn => (zaloLoginResult?.oauthCode ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initZalo();
  }

  Future<void> _guard(int step, String label, Future<void> Function() action) async {
    setState(() => _loadingStep = step);
    try {
      await action();
    } catch (e) {
      log('$label error: $e');
      _toast('$label error: $e');
    } finally {
      if (mounted) setState(() => _loadingStep = 0);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 4)));
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    _toast('$label copied');
  }

  void _initZalo() => _guard(1, 'Init', () async {
        final String hashKey = await ZaloLogin().init();
        setState(() => _hashKey = hashKey);
        log('hashKey: $hashKey');
        _toast('Init success');
      });

  void _loginZalo() => _guard(2, 'Login', () async {
        final ZaloLoginResult res = await ZaloLogin().logIn();
        setState(() {
          zaloLoginResult = res;
          zaloInfo = null;
          _authChecked = false;
        });
        log('login: ${res.toJson()}');
        _toast((res.oauthCode ?? '').isNotEmpty ? 'Login success' : 'Login failed (${res.errorCode})');
      });

  void _isAuthenticated() => _guard(3, 'Check Auth', () async {
        final bool isAuth = await ZaloLogin().isAuthenticated();
        setState(() {
          _authenticated = isAuth;
          _authChecked = true;
        });
        _toast('Is Authenticated: $isAuth');
      });

  void _getInfo() => _guard(4, 'Get Info', () async {
        final ZaloProfileModel info = await ZaloLogin().getInfo();
        setState(() => zaloInfo = info);
        log('profile: ${info.toJson()}');
        _toast('Got profile: ${info.name}');
      });

  void _logout() => _guard(5, 'Logout', () async {
        await ZaloLogin().logOut();
        setState(() {
          zaloLoginResult = null;
          zaloInfo = null;
          _authenticated = false;
          _authChecked = false;
        });
        _toast('Logged out');
      });

  void _sheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                TextButton.icon(
                  onPressed: () => _copy(title, content),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                ),
              ]),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  child: SelectableText(content, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final String? profileJson = zaloInfo == null
        ? null
        : const JsonEncoder.withIndent('  ').convert(zaloInfo!.toJson());
    final String? loginJson = zaloLoginResult == null
        ? null
        : const JsonEncoder.withIndent('  ').convert(zaloLoginResult!.toJson());

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: kZaloBlue,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Step 1 — Init
              _StepTile(
                number: 1,
                title: 'Init',
                actionLabel: 'Init Zalo',
                loading: _loadingStep == 1,
                enabled: !_busy,
                done: _inited,
                onAction: _initZalo,
                result: _inited ? 'hashKey: $_hashKey' : 'Get the Android hash key',
                onCopy: _inited ? () => _copy('Hash key', _hashKey) : null,
                onDetails: _inited ? () => _sheet('Android Hash Key', _hashKey) : null,
                copyTooltip: 'Copy hash key',
                detailsTooltip: 'Details hash key',
              ),
              // Step 2 — Login
              _StepTile(
                number: 2,
                title: 'Login',
                actionLabel: 'Login Zalo',
                loading: _loadingStep == 2,
                enabled: !_busy && _inited,
                done: _loggedIn,
                onAction: _loginZalo,
                result: _loggedIn
                    ? 'oauthCode: ${zaloLoginResult!.oauthCode}'
                    : (zaloLoginResult != null
                        ? 'errorCode: ${zaloLoginResult!.errorCode}'
                        : 'Login with Zalo (app / QR / web)'),
                onCopy: _loggedIn ? () => _copy('oauthCode', zaloLoginResult!.oauthCode ?? '') : null,
                onDetails: loginJson != null ? () => _sheet('Login Result', loginJson) : null,
                copyTooltip: 'Copy oauth code',
                detailsTooltip: 'Details login',
              ),
              // Step 3 — Is Authenticated
              _StepTile(
                number: 3,
                title: 'Is Auth',
                actionLabel: 'Check Auth',
                loading: _loadingStep == 3,
                enabled: !_busy,
                done: _authChecked && _authenticated,
                onAction: _isAuthenticated,
                result: _authChecked
                    ? 'Is Authenticated: $_authenticated'
                    : 'Is Authenticated: (tap to check)',
                detailsTooltip: 'Details auth',
                onDetails: _authChecked
                    ? () => _sheet('Is Authenticated: $_authenticated',
                        'Checked via ZaloLogin().isAuthenticated()\nresult: $_authenticated')
                    : null,
              ),
              // Step 4 — Get info
              _StepTile(
                number: 4,
                title: 'Info',
                actionLabel: 'Get info',
                loading: _loadingStep == 4,
                enabled: !_busy && _loggedIn,
                done: zaloInfo?.id?.isNotEmpty ?? false,
                onAction: _getInfo,
                avatarUrl: zaloInfo?.picture?.data?.url,
                result: (zaloInfo?.id?.isNotEmpty ?? false)
                    ? 'name: ${zaloInfo!.name}  |  id: ${zaloInfo!.id}'
                    : 'Get user profile',
                onCopy: profileJson != null ? () => _copy('Profile', profileJson) : null,
                onDetails: profileJson != null ? () => _sheet('Profile (full data)', profileJson) : null,
                copyTooltip: 'Copy profile',
                detailsTooltip: 'Details profile',
              ),
              // Step 5 — Logout
              _StepTile(
                number: 5,
                title: 'Logout',
                actionLabel: 'Logout',
                loading: _loadingStep == 5,
                enabled: !_busy,
                done: false,
                onAction: _logout,
                result: _loggedIn ? 'Session active — tap to clear' : 'Logged out / no session',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact numbered step: [n] title + action button + inline result,
/// with optional copy and "details" (bottom sheet) affordances.
class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.actionLabel,
    required this.enabled,
    required this.loading,
    required this.done,
    required this.onAction,
    required this.result,
    this.onCopy,
    this.onDetails,
    this.avatarUrl,
    this.copyTooltip = 'Copy',
    this.detailsTooltip = 'Details',
  });

  final int number;
  final String title;
  final String actionLabel;
  final bool enabled;
  final bool loading;
  final bool done;
  final VoidCallback onAction;
  final String result;
  final VoidCallback? onCopy;
  final VoidCallback? onDetails;
  final String? avatarUrl;
  final String copyTooltip;
  final String detailsTooltip;

  @override
  Widget build(BuildContext context) {
    final Color numColor = done ? Colors.green : kZaloBlue;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: number, title, actions, button
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: numColor.withValues(alpha: 0.15),
                  child: done
                      ? Icon(Icons.check, size: 18, color: numColor)
                      : Text('$number', style: TextStyle(color: numColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                if (avatarUrl != null && avatarUrl!.isNotEmpty) ...[
                  CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl!)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text('$number. $title',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                if (onCopy != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: copyTooltip,
                  ),
                if (onDetails != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onDetails,
                    icon: const Icon(Icons.unfold_more, size: 20),
                    tooltip: detailsTooltip,
                  ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 96,
                  height: 38,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kZaloBlue,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: (enabled && !loading) ? onAction : null,
                    child: loading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(actionLabel, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Row 2: result on its own line (no interactive siblings -> Maestro
            // reads it reliably).
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                result,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
