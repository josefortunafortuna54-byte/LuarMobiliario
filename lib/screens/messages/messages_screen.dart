import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/message_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/avatar_widget.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<_Conversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _conversations = _mockConversations;
      _isLoading = false;
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            )
          : _conversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  color: AppColors.gold,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 80,
                      endIndent: 16,
                      color: AppColors.gray100,
                    ),
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return _buildConversationTile(conversation);
                    },
                  ),
                ),
    );
  }

  Widget _buildConversationTile(_Conversation conversation) {
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        splashColor: AppColors.gold.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              AvatarWidget(
                imageUrl: conversation.avatarUrl,
                name: conversation.name,
                size: AvatarSize.medium,
                showOnlineIndicator: conversation.isOnline,
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
                            conversation.name,
                            style: hasUnread
                                ? AppTextStyles.bodyMediumBold
                                : AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(conversation.lastMessageTime),
                          style: AppTextStyles.bodyTiny.copyWith(
                            color: hasUnread
                                ? AppColors.gold
                                : AppColors.gray400,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: hasUnread
                                  ? AppColors.gray800
                                  : AppColors.gray500,
                              fontWeight:
                                  hasUnread ? FontWeight.w500 : FontWeight.w400,
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
                                conversation.unreadCount > 9
                                    ? '9+'
                                    : '${conversation.unreadCount}',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sem mensagens',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Suas conversas com corretores e vendedores aparecerão aqui.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Conversation {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const _Conversation({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });
}

final List<_Conversation> _mockConversations = [
  _Conversation(
    id: '1',
    name: 'Carlos Mendes',
    avatarUrl: '',
    lastMessage: 'O imóvel ainda está disponível?',
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 2,
    isOnline: true,
  ),
  _Conversation(
    id: '2',
    name: 'Ana Ferreira',
    avatarUrl: '',
    lastMessage: 'Podemos agendar uma visita para sábado?',
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
    unreadCount: 1,
    isOnline: false,
  ),
  _Conversation(
    id: '3',
    name: 'Pedro Santos',
    avatarUrl: '',
    lastMessage: 'Obrigado pelas informações!',
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
    unreadCount: 0,
    isOnline: true,
  ),
  _Conversation(
    id: '4',
    name: 'Maria João',
    avatarUrl: '',
    lastMessage: 'Enviei as fotos do apartamento por WhatsApp',
    lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 0,
    isOnline: false,
  ),
  _Conversation(
    id: '5',
    name: 'Ricardo Almeida',
    avatarUrl: '',
    lastMessage: 'Qual o valor de condomínio?',
    lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
    unreadCount: 0,
    isOnline: false,
  ),
];
