import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Share preview sheet: truthful summary of what the job-card PDF contains,
/// then shares the REAL generated file via the caller's `onSharePdf`.
/// Errors stay in-sheet with retry; toasts fire only on actual share/failure.
/// Shared by the job detail dossier and the intake sign-off deck.
class SharePreviewSheet extends StatefulWidget {
  final String summary;
  final String link;
  final int linesCount;
  final int commentsCount;
  final bool customerSigned;
  final bool advisorSigned;
  final String totalValue;
  final Future<bool> Function() onSharePdf;

  const SharePreviewSheet({
    super.key,
    required this.summary,
    required this.link,
    required this.linesCount,
    required this.commentsCount,
    required this.customerSigned,
    required this.advisorSigned,
    required this.totalValue,
    required this.onSharePdf,
  });

  @override
  State<SharePreviewSheet> createState() => SharePreviewSheetState();
}

class SharePreviewSheetState extends State<SharePreviewSheet> {
  bool _building = false;
  bool _failed = false;

  Future<void> _share() async {
    setState(() {
      _building = true;
      _failed = false;
    });
    final ok = await widget.onSharePdf();
    if (!mounted) return;
    setState(() {
      _building = false;
      _failed = !ok;
    });
    if (ok && mounted) Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: t.advisorClientShareTitle,
            leadingIcon: Icons.share_outlined,
            padding: const EdgeInsets.only(bottom: AppDimensions.s12),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              widget.link.isEmpty
                  ? widget.summary
                  : '${widget.summary}\n${widget.link}',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.mono(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          Text(
            '${t.advisorClientPdfWork}: ${widget.linesCount} · '
            '${t.advisorClientComments}: ${widget.commentsCount} · '
            '${t.advisorClientSignatures}: '
            '${(widget.customerSigned ? 1 : 0) + (widget.advisorSigned ? 1 : 0)}/2',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (widget.totalValue.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                widget.totalValue,
                style: AppTextStyles.mono(color: colors.onSurface),
              ),
            ),
          ],
          if (_failed) ...[
            const SizedBox(height: AppDimensions.s8),
            Text(
              t.advisorClientSharePdfFail,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s16),
          PrimaryButton(
            label: _building
                ? t.advisorClientSharePdfBuilding
                : t.advisorClientSharePdf,
            icon: _building ? null : Icons.picture_as_pdf_outlined,
            onPressed: _building ? null : _share,
          ),
          const SizedBox(height: AppDimensions.s8),
          TextButton(
            onPressed: _building ? null : () => Navigator.maybePop(context),
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurfaceVariant,
              minimumSize: const Size(0, AppDimensions.touchTarget),
            ),
            child: Text(t.advisorActionClose),
          ),
        ],
      ),
    );
  }
}
