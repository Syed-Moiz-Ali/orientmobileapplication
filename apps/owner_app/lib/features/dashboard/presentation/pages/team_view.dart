import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/attendance_provider.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Clock-in state for one roster row, joined by staff id against the loaded
/// day register. Unmatched (or still loading) renders no pill at all — an
/// absent record is not proof of absence.
enum _ClockState { onShift, offShift }

_ClockState? _clockFor(StaffMember member, OwnerAttendanceState attendance) {
  if (attendance.isLoading) return null;
  for (final record in attendance.records) {
    if (record.staffId.isNotEmpty && record.staffId == member.id) {
      return record.status == 'working' || record.status == 'onBreak'
          ? _ClockState.onShift
          : _ClockState.offShift;
    }
  }
  return null;
}

/// Staff roster (O11): directory header with role counts, search + role
/// filter, member cards with role/active pills and today's clock state, and
/// the validated add-member + enable/disable flows. Add/toggle call the
/// frozen notifier; only chrome, copy and states are new. Overtime and
/// commission have no endpoint fields and are deferred, not fabricated.
class TeamView extends ConsumerStatefulWidget {
  const TeamView({super.key});

  @override
  ConsumerState<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends ConsumerState<TeamView> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _selectedRole = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(teamProvider);
    final notifier = ref.read(teamProvider.notifier);
    final attendance = ref.watch(ownerAttendanceProvider);

    final query = _searchCtrl.text.trim().toLowerCase();
    final filteredStaff = state.staff.where((m) {
      final matchesRole =
          _selectedRole == 'all' ||
          m.role.toLowerCase() == _selectedRole.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.empId.toLowerCase().contains(query) ||
          m.phone.toLowerCase().contains(query) ||
          m.branch.toLowerCase().contains(query) ||
          m.role.toLowerCase().contains(query);
      return matchesRole && matchesQuery;
    }).toList();

    final activeCount = state.staff.where((m) => m.isActive).length;
    final advisorCount = state.staff
        .where((m) => m.role.toLowerCase() == 'advisor')
        .length;
    final supervisorCount = state.staff
        .where((m) => m.role.toLowerCase() == 'supervisor')
        .length;
    final techCount = state.staff
        .where((m) => m.role.toLowerCase() == 'technician')
        .length;
    final roles = <String>[
      t.ownerTmAdvisors,
      t.ownerTmSupervisors,
      t.ownerTmTechnicians,
    ];
    final roleValues = <String>['advisor', 'supervisor', 'technician'];
    final counts = <String, int>{
      SharedCoreL10n.of(context).filterBarAll: state.staff.length,
      t.ownerTmAdvisors: state.staff
          .where((m) => m.role.toLowerCase() == 'advisor')
          .length,
      t.ownerTmSupervisors: state.staff
          .where((m) => m.role.toLowerCase() == 'supervisor')
          .length,
      t.ownerTmTechnicians: state.staff
          .where((m) => m.role.toLowerCase() == 'technician')
          .length,
    };

    return WorkspaceSearchShortcuts(
      onSearch: () => _searchFocus.requestFocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: WorkspaceAppBar(
          title: t.ownerTmTitle,
          subtitle: t.ownerTmSubtitle(activeCount, state.staff.length),
          showBack: true,
          showOfflineStatus: true,
          actions: [
            IconButton(
              tooltip: MaterialLocalizations.of(
                context,
              ).refreshIndicatorSemanticLabel,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                HapticFeedback.selectionClick();
                notifier.load();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 3,
          onPressed: () =>
              _showAddStaffSheet(context, notifier, state.branches),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text(
            t.ownerTmAdd,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: state.isLoading && state.staff.isEmpty
              ? const AppSkeleton.page()
              : state.error.isNotEmpty && state.staff.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.s20),
                    child: ErrorView(
                      message: state.error,
                      onRetry: notifier.load,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => notifier.load(),
                  color: colors.primary,
                  child: AppResponsivePage(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DirectoryHeader(
                          activeCount: activeCount,
                          total: state.staff.length,
                          advisors: advisorCount,
                          supervisors: supervisorCount,
                          technicians: techCount,
                        ),
                        const SizedBox(height: AppDimensions.s12),
                        AppSearchField(
                          controller: _searchCtrl,
                          focusNode: _searchFocus,
                          hintText: t.ownerTmSearchHint,
                          onChanged: (_) => setState(() {}),
                          onClear: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: AppDimensions.s12),
                        AppFilterBar(
                          options: roles,
                          selected: _selectedRole == 'all'
                              ? null
                              : roles[roleValues.indexOf(_selectedRole)],
                          counts: counts,
                          onSelected: (label) => setState(() {
                            if (label == null) {
                              _selectedRole = 'all';
                            } else {
                              final i = roles.indexOf(label);
                              _selectedRole = i < 0 ? 'all' : roleValues[i];
                            }
                          }),
                        ),
                        const SizedBox(height: AppDimensions.s12),
                        if (filteredStaff.isEmpty)
                          EmptyState(
                            icon: Icons.person_off_outlined,
                            message: t.ownerTmEmpty,
                          )
                        else
                          _RosterList(
                            staff: filteredStaff,
                            attendance: attendance,
                            notifier: notifier,
                          ),
                        const SizedBox(height: 96),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _showAddStaffSheet(
    BuildContext context,
    TeamNotifier notifier,
    List<BranchOption> branches,
  ) async {
    HapticFeedback.selectionClick();
    final createdName = await showAppModalSheet<String>(
      context: context,
      builder: (sheetContext) =>
          _AddMemberSheet(notifier: notifier, branches: branches),
    );
    if (!context.mounted) return;
    if (createdName == null || createdName.isEmpty) return;
    final t = OwnerLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.verified_user_rounded, size: 38),
        title: Text(t.ownerTmCreated),
        content: Text(
          '$createdName\n\n${t.ownerTmCreatedBody}',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.ownerTmDone),
          ),
        ],
      ),
    );
  }
}

/// Directory header: active pill plus per-role compact KPIs. Counts derive
/// from the frozen roster list.
class _DirectoryHeader extends StatelessWidget {
  final int activeCount;
  final int total;
  final int advisors;
  final int supervisors;
  final int technicians;

  const _DirectoryHeader({
    required this.activeCount,
    required this.total,
    required this.advisors,
    required this.supervisors,
    required this.technicians,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    // Counts ride along from the caller so they can never drift from the
    // roster list below.
    final counts = [advisors, supervisors, technicians];
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.s8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(
                  Icons.badge_rounded,
                  color: colors.primary,
                  size: AppDimensions.iconSm,
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  t.ownerTmDirectory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              StatusPill.success(
                '$activeCount / $total ${t.ownerTmActive}',
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Row(
            children: [
              Expanded(
                child: AppKpiCard.compact(
                  label: t.ownerTmAdvisors,
                  value: '${counts[0]}',
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: AppKpiCard.compact(
                  label: t.ownerTmSupervisors,
                  value: '${counts[1]}',
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Expanded(
                child: AppKpiCard.compact(
                  label: t.ownerTmTechnicians,
                  value: '${counts[2]}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Roster rows: avatar, name, role pill + id, active pill + enable switch,
/// today's clock pill when the day register names them, branch/phone
/// footer. Decorative role colors are gone; tone carries meaning.
class _RosterList extends StatelessWidget {
  final List<StaffMember> staff;
  final OwnerAttendanceState attendance;
  final TeamNotifier notifier;

  const _RosterList({
    required this.staff,
    required this.attendance,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );
    final medium = context.adaptive.pick(
      compact: false,
      medium: true,
      expanded: true,
      large: true,
    );

    Widget card(StaffMember m) => _StaffCard(
      member: m,
      clock: _clockFor(m, attendance),
      notifier: notifier,
    );

    if (wide || medium) {
      const columns = 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: staff.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppDimensions.s12,
          mainAxisSpacing: AppDimensions.s12,
          // Fits the avatar row plus the branch/phone footer at 1.3x.
          mainAxisExtent: 176,
        ),
        itemBuilder: (_, i) => card(staff[i]),
      );
    }
    return Column(
      children: [
        for (final m in staff) ...[
          card(m),
          const SizedBox(height: AppDimensions.s12),
        ],
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffMember member;
  final _ClockState? clock;
  final TeamNotifier notifier;

  const _StaffCard({
    required this.member,
    required this.clock,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard.standard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: member.isActive
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.surfaceContainerHighest,
                child: Text(
                  member.name.isNotEmpty
                      ? member.name.characters.first.toUpperCase()
                      : '?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: member.isActive
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: AppDimensions.s6,
                      runSpacing: AppDimensions.s4,
                      children: [
                        StatusPill.neutral(member.role.toUpperCase()),
                        if (clock == _ClockState.onShift)
                          StatusPill.success(t.ownerTmOnShift, showDot: true)
                        else if (clock == _ClockState.offShift)
                          StatusPill.neutral(t.ownerTmOffShift),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Column(
                children: [
                  member.isActive
                      ? StatusPill.success(t.ownerTmActive, showDot: true)
                      : StatusPill.danger(t.ownerTmOff, showDot: true),
                  Switch.adaptive(
                    value: member.isActive,
                    onChanged: (_) {
                      HapticFeedback.selectionClick();
                      notifier.toggleActive(member);
                    },
                  ),
                ],
              ),
            ],
          ),
          if (member.phone.isNotEmpty || member.branch.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s10),
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                if (member.branch.isNotEmpty) ...[
                  Icon(
                    Icons.store_outlined,
                    size: AppDimensions.iconXs,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.s6),
                  Expanded(
                    child: Text(
                      member.branch,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (member.phone.isNotEmpty) ...[
                  Icon(
                    Icons.phone_outlined,
                    size: AppDimensions.iconXs,
                    color: colors.primary,
                  ),
                  const SizedBox(width: AppDimensions.s6),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      member.phone,
                      style: AppTextStyles.mono(
                        color: colors.primary,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Frozen role values stay English in state; only the rendered labels
/// localize — presentation-only mapping.
String _roleLabel(OwnerLocalizations t, String value) => switch (value) {
  'supervisor' => t.ownerTmSupervisors,
  'technician' => t.ownerTmTechnicians,
  _ => t.ownerTmAdvisors,
};

String _roleValue(OwnerLocalizations t, String label) {
  if (label == t.ownerTmSupervisors) return 'supervisor';
  if (label == t.ownerTmTechnicians) return 'technician';
  return 'advisor';
}

/// Add-member sheet: the frozen `addMember` contract with shared inputs.
/// Validation mirrors the old rules with localized copy; the provider's
/// error string toasts on failure and the created dialog confirms success.
class _AddMemberSheet extends StatefulWidget {
  final TeamNotifier notifier;
  final List<BranchOption> branches;

  const _AddMemberSheet({required this.notifier, required this.branches});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _name = TextEditingController();
  final _empId = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _shift = TextEditingController();
  final _designation = TextEditingController();
  final _department = TextEditingController();
  String _role = 'advisor';
  String? _branchId;
  bool _busy = false;
  String? _error;
  final _scroll = ScrollController();
  final _errors = <String, String?>{};

  @override
  void dispose() {
    _name.dispose();
    _empId.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _shift.dispose();
    _designation.dispose();
    _department.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String? _required(OwnerLocalizations t, String value) =>
      value.trim().isEmpty ? t.ownerReqRequired : null;

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _submit() async {
    final t = OwnerLocalizations.of(context)!;
    final errors = <String, String?>{
      'name': _required(t, _name.text),
      'empId': _required(t, _empId.text),
      'phone': _phone.text.replaceAll(RegExp(r'[^0-9]'), '').length < 8
          ? t.ownerReqPhone
          : null,
      'email': () {
        final email = _email.text.trim();
        return !email.contains('@') || !email.contains('.')
            ? t.ownerReqEmail
            : null;
      }(),
      'password': _password.text.length < 8 ? t.ownerReqPassword : null,
      'confirm': _confirm.text != _password.text ? t.ownerReqMatch : null,
      'branch': widget.branches.isNotEmpty && _branchId == null
          ? t.ownerReqRequired
          : null,
    };
    final firstError = errors.values.whereType<String>().firstOrNull;
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
      _error = firstError;
    });
    if (firstError != null) {
      _scrollToEnd();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final branchName = widget.branches
        .where((b) => b.id == _branchId)
        .map((b) => b.name)
        .firstOrNull;
    final error = await widget.notifier.addMember({
      'name': _name.text.trim(),
      'empId': _empId.text.trim().toUpperCase(),
      'role': _role,
      'phone': _phone.text.trim(),
      'email': _email.text.trim().toLowerCase(),
      'password': _password.text,
      if (_branchId != null) 'branchId': int.parse(_branchId!),
      'branch': branchName ?? '',
      'shift': _shift.text.trim(),
      'designation': _designation.text.trim(),
      'department': _department.text.trim(),
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error != null) {
      _scrollToEnd();
      return;
    }
    Navigator.pop(context, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s20,
        ),
        child: SingleChildScrollView(
          controller: _scroll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: SectionHeader(
                  title: t.ownerTmAddTitle,
                  subtitle: t.ownerTmAddSubtitle,
                  padding: const EdgeInsets.only(bottom: AppDimensions.s12),
                ),
              ),
              AppTextField(
                controller: _name,
                label: t.ownerTmName,
                hint: t.ownerTmName,
                errorText: _errors['name'],
              ),
              const SizedBox(height: AppDimensions.s12),
              AppTextField(
                controller: _empId,
                label: t.ownerTmEmpId,
                hint: t.ownerTmEmpId,
                errorText: _errors['empId'],
              ),
              const SizedBox(height: AppDimensions.s12),
              AppDropdownButton(
                value: _roleLabel(t, _role),
                items: [
                  _roleLabel(t, 'advisor'),
                  _roleLabel(t, 'supervisor'),
                  _roleLabel(t, 'technician'),
                ],
                label: t.ownerTmRole,
                onChanged: (v) => setState(() => _role = _roleValue(t, v)),
              ),
              const SizedBox(height: AppDimensions.s16),
              Text(
                t.ownerTmLogin,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppDimensions.s10),
              AppTextField(
                controller: _phone,
                label: t.ownerTmPhone,
                hint: t.ownerTmPhone,
                keyboardType: TextInputType.phone,
                errorText: _errors['phone'],
              ),
              const SizedBox(height: AppDimensions.s12),
              AppTextField(
                controller: _email,
                label: t.ownerTmEmail,
                hint: t.ownerTmEmail,
                keyboardType: TextInputType.emailAddress,
                errorText: _errors['email'],
              ),
              const SizedBox(height: AppDimensions.s12),
              AppTextField(
                controller: _password,
                label: t.ownerTmPassword,
                hint: t.ownerTmPassword,
                obscureText: true,
                errorText: _errors['password'],
              ),
              const SizedBox(height: AppDimensions.s12),
              AppTextField(
                controller: _confirm,
                label: t.ownerTmPassword2,
                hint: t.ownerTmPassword2,
                obscureText: true,
                errorText: _errors['confirm'],
              ),
              const SizedBox(height: AppDimensions.s8),
              Text(
                t.ownerTmOtpNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
              Text(
                t.ownerTmWork,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppDimensions.s10),
              AppTextField(
                controller: _designation,
                label: t.ownerTmDesignation,
                hint: t.ownerTmDesignation,
              ),
              const SizedBox(height: AppDimensions.s12),
              AppTextField(
                controller: _department,
                label: t.ownerTmDepartment,
                hint: t.ownerTmDepartment,
              ),
              const SizedBox(height: AppDimensions.s12),
              AppDropdownButton(
                value:
                    widget.branches
                        .where((b) => b.id == _branchId)
                        .map((b) => b.name)
                        .firstOrNull ??
                    '',
                items: [for (final b in widget.branches) b.name],
                label: t.ownerTmBranch,
                hint: widget.branches.isEmpty
                    ? t.ownerTmNoBranches
                    : t.ownerTmBranchHint,
                enabled: widget.branches.isNotEmpty,
                onChanged: (name) {
                  final match = widget.branches
                      .where((b) => b.name == name)
                      .firstOrNull;
                  setState(() => _branchId = match?.id);
                },
              ),
              if (_errors['branch'] != null) ...[
                const SizedBox(height: AppDimensions.s6),
                Text(
                  _errors['branch']!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.s12),
              AppTextField(
                controller: _shift,
                label: t.ownerTmShift,
                hint: t.ownerTmShift,
              ),
              const SizedBox(height: AppDimensions.s20),
              if (_error != null) ...[
                AppBanner(
                  kind: AppBannerKind.error,
                  message: _error!,
                  onDismiss: () => setState(() => _error = null),
                ),
                const SizedBox(height: AppDimensions.s12),
              ],
              PrimaryButton(
                label: t.ownerTmSubmit,
                icon: Icons.person_add_alt_1_rounded,
                isLoading: _busy,
                onPressed: _busy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
