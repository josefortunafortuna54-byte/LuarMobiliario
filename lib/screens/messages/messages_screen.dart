import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/message_provider.dart';
import '../../core/utils/routes.dart';
import '../../widgets/avatar_widget.dart';
import '../../components/empty_state.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<MessageProvider>().loadConversations(userId);
      }
    });
  }

  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inMinutes < 1) return 'Agora';
      if (diff.inMinutes < 60) return '${diff.inMinutes}min';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mensagens',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.conversations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            );
          }

          if (provider.conversations.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Sem mensagens',
              subtitle: 'Suas conversas com corretores e vendedores aparecerão aqui.',
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              final userId = context.read<AuthProvider>().user?.id;
              if (userId != null) {
                return provider.loadConversations(userId);
              }
              return Future.value();
            },
            color: AppColors.gold,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.conversations.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 80,
                endIndent: 16,
                color: AppColors.gray100,
              ),
              itemBuilder: (context, index) {
                final conv = provider.conversations[index];
                final hasUnread = (conv['unreadCount'] ?? 0) > 0;
                return _buildConversationTile(conv, hasUnread);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conv, bool hasUnread) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.chat,
            arguments: {
              'partnerId': conv['partnerId'],
              'partnerName': conv['partnerName'],
            },
          );
        },
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        splashColor: AppColors.gold.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              AvatarWidget(
                imageUrl: conv['partnerAvatar'] ?? '',
                name: conv['partnerName'] ?? '',
                size: AvatarSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv['partnerName'] ?? '',
                            style: hasUnread
                                ? AppTextStyles.bodyMediumBold
                                : AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(conv['lastMessageTime'] ?? ''),
                          style: AppTextStyles.bodyTiny.copyWith(
                            color: hasUnread ? AppColors.gold : AppColors.gray400,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv['lastMessage'] ?? '',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: hasUnread ? AppColors.gray800 : AppColors.gray500,
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.goldGradient,
                            ),
                            child: Center(
                              child: Text(
                                '${conv['unreadCount'] ?? 0}',
                                style: AppTextStyles.bodyTiny.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
