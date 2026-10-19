import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';
import 'package:crm_app/l10n/gen/crm_localizations.dart';

class ConnectIntegrationSheet extends ConsumerStatefulWidget {
  final String? initialPlatform;
  const ConnectIntegrationSheet({super.key, this.initialPlatform});

  static Future<void> show(BuildContext context, {String? platform}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ConnectIntegrationSheet(initialPlatform: platform),
    );
  }

  @override
  ConsumerState<ConnectIntegrationSheet> createState() => _ConnectIntegrationSheetState();
}

class _PlatformDef {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _PlatformDef(this.name, this.subtitle, this.icon, this.color);
}

class _ConnectIntegrationSheetState extends ConsumerState<ConnectIntegrationSheet> {
  static List<_PlatformDef> _platforms(CrmLocalizations t) => [
    _PlatformDef('META', t.csMetaSub, Icons.facebook_rounded, const Color(0xFF1877F2)),
    _PlatformDef('ZOHO', t.csZohoSub, Icons.work_rounded, const Color(0xFFF0483E)),
  ];

  late String _selected;
  final _pageIdCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _clientIdCtrl = TextEditingController();
  final _clientSecretCtrl = TextEditingController();
  final _refreshTokenCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  /// Platform ids are backend values; only subtitles localize.
  static const _platformNames = ['META', 'ZOHO'];

  @override
  void initState() {
    super.initState();
    _selected = _platformNames.contains(widget.initialPlatform)
        ? widget.initialPlatform!
        : _platformNames.first;
  }

  @override
  void dispose() {
    _pageIdCtrl.dispose();
    _tokenCtrl.dispose();
    _clientIdCtrl.dispose();
    _clientSecretCtrl.dispose();
    _refreshTokenCtrl.dispose();
    super.dispose();
  }

  bool get _isMeta => _selected == 'META';

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CrmColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              t.csTitle,
              style: TextStyle(
                color: CrmColors.textH,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.csSub,
              style: TextStyle(color: CrmColors.textM, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ..._platforms(context.cx).map((p) => _platformCard(p)),
            const SizedBox(height: 18),
            if (_isMeta) ...[
              _fieldLabel(t.csPageId),
              _credField(t.csPageId, t.csPageIdHint, _pageIdCtrl),
              const SizedBox(height: 12),
              _fieldLabel(t.csToken),
              _credField(t.csTokenHint, 'EAAG...', _tokenCtrl, obscure: true),
              const SizedBox(height: 8),
              _hintRow(Icons.info_outline_rounded,
                  t.csMetaHelp),
            ] else ...[
              _fieldLabel(t.csClientId),
              _credField(t.csClientIdHint, '1000.XXXX', _clientIdCtrl),
              const SizedBox(height: 12),
              _fieldLabel(t.csSecret),
              _credField(t.csSecretHint, '••••••••', _clientSecretCtrl, obscure: true),
              const SizedBox(height: 12),
              _fieldLabel(t.csRefresh),
              _credField(t.csRefreshHint, '1000.XXXX.XXXX', _refreshTokenCtrl, obscure: true),
              const SizedBox(height: 8),
              _hintRow(Icons.info_outline_rounded,
                  t.csZohoHelp),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CrmColors.redBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: CrmColors.red, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _connect,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.link_rounded, size: 18),
                label: Text(_busy ? t.csConnecting : t.csConnect(_selected)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CrmColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _platformCard(_PlatformDef p) {
    final selected = _selected == p.name;
    return GestureDetector(
      onTap: () => setState(() => _selected = p.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? p.color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? p.color : CrmColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: p.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(p.icon, color: p.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: CrmColors.textH,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.subtitle,
                    style: const TextStyle(color: CrmColors.textM, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? p.color : CrmColors.border,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: CrmColors.textM,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _credField(String hint, String example, TextEditingController ctrl,
      {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: CrmColors.textH, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: CrmColors.textM, fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CrmColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CrmColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CrmColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _hintRow(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 13, color: CrmColors.textM),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: CrmColors.textM, fontSize: 10.5, height: 1.4),
        ),
      ),
    ],
  );

  Future<void> _connect() async {
    final t = context.cx;
    final credentials = <String, String>{};
    if (_isMeta) {
      if (_pageIdCtrl.text.trim().isEmpty || _tokenCtrl.text.trim().isEmpty) {
        setState(() => _error = t.csNeedMeta);
        return;
      }
      credentials['pageId'] = _pageIdCtrl.text.trim();
      credentials['accessToken'] = _tokenCtrl.text.trim();
    } else {
      if (_clientIdCtrl.text.trim().isEmpty ||
          _clientSecretCtrl.text.trim().isEmpty ||
          _refreshTokenCtrl.text.trim().isEmpty) {
        setState(() => _error = t.csNeedZoho);
        return;
      }
      credentials['clientId'] = _clientIdCtrl.text.trim();
      credentials['clientSecret'] = _clientSecretCtrl.text.trim();
      credentials['refreshToken'] = _refreshTokenCtrl.text.trim();
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(crmUiProvider.notifier).connectIntegration(_selected, credentials);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.connected) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.csDone(_selected)),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _error = t.csFail);
    }
  }
}
