import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/form_label.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/message_tile.dart';

const _users = [
  'Ahmed Service Advisor', 'Mohammed Technician', 'Ali Workshop Manager',
  'Hassan Accountant', 'Omar Parts Manager', 'Fatima Admin', 'Sarah HR Manager',
];

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  late TextEditingController _msgController;

  @override
  void initState() {
    super.initState();
    _msgController = TextEditingController(
      text: ref.read(dashboardUiProvider).messageText,
    );
    _msgController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    ref.read(dashboardUiProvider.notifier).updateMessage(_msgController.text);
  }

  @override
  void dispose() {
    _msgController.removeListener(_onMessageChanged);
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.r20),
                  ),
                  child: Text(
                    '${state.sentMessages.length} Sent Messages',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppCard.surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEND NEW MESSAGE',
                  style: AppTextStyles.rajdhaniBodySmall(
                    color: AppColors.text3,
                  ),
                ),
                const SizedBox(height: 14),
                const FormLabel('SELECT USER'),
                const SizedBox(height: 7),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: state.selectedUser.isEmpty
                          ? null
                          : state.selectedUser,
                      hint: Row(
                        children: const [
                          Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.text3,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Choose a user...',
                            style: TextStyle(
                              color: AppColors.text3,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.text3,
                        size: 18,
                      ),
                      isExpanded: true,
                      onChanged: (v) => notifier.selectUser(v ?? ''),
                      items: _users
                          .map(
                            (u) => DropdownMenuItem(value: u, child: Text(u)),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const FormLabel('MESSAGE'),
                const SizedBox(height: 7),
                TextField(
                  controller: _msgController,
                  onChanged: notifier.updateMessage,
                  maxLines: 5,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                    hintStyle: const TextStyle(
                      color: AppColors.text3,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AppColors.canvas,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    notifier.sendMessage();
                    _msgController.clear();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.navy, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.r14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'SEND MESSAGE',
                          style: AppTextStyles.rajdhaniLabel(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (state.sentMessages.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimensions.r2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'RECENT MESSAGES',
                  style: AppTextStyles.rajdhaniButton(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...state.sentMessages.map(
              (msg) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MessageTile(message: msg),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
