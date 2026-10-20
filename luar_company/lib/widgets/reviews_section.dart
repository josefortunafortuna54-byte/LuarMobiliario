import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/models/review_model.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/review_provider.dart';
import '../core/theme/app_palette.dart';
import '../core/utils/formatters.dart';
import '../l10n/app_localizations.dart';
import 'avatar_widget.dart';

/// Secção de avaliações de um imóvel (resumo + lista + ação de avaliar).
/// Mostra no ecrã de detalhe; o utilizador autenticado (que não seja o dono
/// do anúncio) pode criar/atualizar a sua avaliação.
class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key, required this.propertyId, this.agentId});

  final String propertyId;
  final String? agentId;

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().load(widget.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final isAgentOwner = user != null && user.id == widget.agentId;

    return Consumer<ReviewProvider>(
      builder: (_, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(provider, l10n, palette),
              const SizedBox(height: 12),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _buildSummary(provider, l10n, palette),
                const SizedBox(height: 16),
                _buildAction(provider, user?.id, isAgentOwner, l10n),
                if (provider.reviews.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...provider.reviews.map(
                    (r) => _buildReviewItem(r, palette, l10n),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    ReviewProvider provider,
    AppLocalizations l10n,
    dynamic palette,
  ) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 22, color: AppColors.gold),
        const SizedBox(width: 8),
        Text(
          l10n.avaliacoes,
          style: AppTextStyles.h6.copyWith(color: palette.textTitle),
        ),
        const Spacer(),
        if (provider.count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  provider.averageRating.toStringAsFixed(1),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummary(
    ReviewProvider provider,
    AppLocalizations l10n,
    dynamic palette,
  ) {
    if (provider.count == 0) {
      return Text(
        l10n.semAvaliacoes,
        style: AppTextStyles.bodyMedium.copyWith(color: palette.textMuted),
      );
    }

    return Row(
      children: [
        Text(
          provider.averageRating.toStringAsFixed(1),
          style: AppTextStyles.h3.copyWith(color: palette.textTitle),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStars(provider.averageRating, size: 18),
            const SizedBox(height: 2),
            Text(
              l10n.avaliacoesCount(provider.count),
              style: AppTextStyles.bodySmall.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAction(
    ReviewProvider provider,
    String? userId,
    bool isAgentOwner,
    AppLocalizations l10n,
  ) {
    if (userId == null || userId.isEmpty) {
      return Text(
        l10n.avaliacaoRequerLogin,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold),
      );
    }

    if (isAgentOwner) {
      return const SizedBox.shrink();
    }

    final existing = provider.reviewByUser(userId);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openReviewSheet(userId, existing),
        icon: Icon(
          existing != null ? Icons.edit_rounded : Icons.star_border_rounded,
          size: 18,
        ),
        label: Text(
          existing != null ? l10n.atualizarAvaliacao : l10n.avaliar,
          style: AppTextStyles.buttonMedium.copyWith(color: AppColors.navy),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.navy, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(
    ReviewModel review,
    dynamic palette,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(name: review.userName, size: AvatarSize.small),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : '—',
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: palette.textTitle,
                      ),
                    ),
                    Text(
                      formatDate(review.createdAt),
                      style: AppTextStyles.bodyTiny.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStars(review.rating.toDouble(), size: 16),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: AppTextStyles.bodyMedium.copyWith(
                color: palette.textBody,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStars(double rating, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = rating >= index + 1;
        final half = !filled && rating > index;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          size: size,
          color: AppColors.gold,
        );
      }),
    );
  }

  void _openReviewSheet(String userId, ReviewModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewBottomSheet(
        propertyId: widget.propertyId,
        userId: userId,
        existing: existing,
      ),
    );
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  const _ReviewBottomSheet({
    required this.propertyId,
    required this.userId,
    this.existing,
  });

  final String propertyId;
  final String userId;
  final ReviewModel? existing;

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.existing?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existing != null
                    ? l10n.atualizarAvaliacao
                    : l10n.avaliarImovel,
                style: AppTextStyles.h6.copyWith(color: palette.textTitle),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    return IconButton(
                      onPressed: () => setState(() => _rating = value),
                      icon: Icon(
                        _rating >= value
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 36,
                        color: AppColors.gold,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: l10n.escrevaComentario,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          l10n.enviarAvaliacao,
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.avaliacaoInvalida),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final provider = context.read<ReviewProvider>();
    final ok = await provider.submit(
      propertyId: widget.propertyId,
      userId: widget.userId,
      rating: _rating,
      comment: _commentController.text,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.avaliacaoEnviada),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.erroAvaliacao),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
