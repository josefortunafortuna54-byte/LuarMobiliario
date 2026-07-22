import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/message_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/loading_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String _partnerId = '';
  String _partnerName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      if (args != null) {
        _partnerId = args['partnerId'] ?? '';
        _partnerName = args['partnerName'] ?? '';
      }
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null && _partnerId.isNotEmpty) {
        final provider = context.read<MessageProvider>();
        provider.loadMessages(userId, _partnerId);
        provider.subscribeToMessages(userId, _partnerId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<MessageProvider>().unsubscribe();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarWidget(
              name: _partnerName,
              size: AvatarSize.small,
              borderColor: AppColors.gold,
            ),
            const SizedBox(width: 10),
            Text(
              _partnerName,
              style: AppTextStyles.h6.copyWith(color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const LoadingWidget(message: 'Carregando mensagens...');
                }

                if (provider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 64,
                          color: AppColors.gray300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Inicie a conversa',
                          style: AppTextStyles.h6.copyWith(color: AppColors.gray500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Envie uma mensagem para começar',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = provider.messages[index];
                    final userId = context.read<AuthProvider>().user?.id ?? '';
                    final isMine = msg.senderId == userId;
                    return _buildMessageBubble(msg.content, isMine, msg.createdAt);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isMine, DateTime time) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.gold : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMine ? AppColors.white : AppColors.gray800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodyTiny.copyWith(
                color: isMine
                    ? AppColors.white.withValues(alpha: 0.7)
                    : AppColors.gray400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: AppTextStyles.bodyMedium,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Escreva uma mensagem...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.gray50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null || _partnerId.isEmpty) return;

    context.read<MessageProvider>().sendMessage(userId, _partnerId, text);
    _messageController.clear();
    _scrollToBottom();
  }
}
