import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/permissions.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/whatsapp_util.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/access_denied_view.dart';
import '../../widgets/loading_widget.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  bool _accessDenied = false;
  BookingStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      final denied = denyUnlessAdmin(
        context,
        role: user?.role,
        message: AppLocalizations.of(context).acessoRestritoAdmin,
      );
      if (denied) {
        if (mounted) setState(() => _accessDenied = true);
        return;
      }
      context.read<BookingProvider>().loadAllBookings();
    });
  }

  String _targetLabel(AppLocalizations l10n, BookingModel booking) {
    if (booking.propertyTitle.isNotEmpty) return booking.propertyTitle;
    final id = booking.isLand ? (booking.landId ?? '') : booking.propertyId;
    final short = id.length > 8 ? id.substring(0, 8) : id;
    return l10n.imovelCurto(short.isEmpty ? l10n.naoInformado : short);
  }

  Future<void> _updateStatus(BookingModel booking, BookingStatus status) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<BookingProvider>();
    final ok = await provider.updateBookingStatus(booking.id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.agendamentoAtualizado : l10n.erroAtualizarDados,
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _openWhatsApp(BookingModel booking) async {
    final message =
        'Olá${booking.userName.isNotEmpty ? ' ${booking.userName}' : ''}! '
        'Sobre a sua visita (${_targetLabel(AppLocalizations.of(context), booking)}) '
        'agendada para ${_formatDate(booking.date)} às ${booking.time}.';
    await WhatsAppUtil.open(message: message, phone: booking.userPhone);
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (_accessDenied) {
      return Scaffold(
        backgroundColor: palette.surface,
        body: AccessDeniedView(
          message: AppLocalizations.of(context).acessoRestritoAdmin,
        ),
      );
    }
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.agendamentos,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.contentMaxWidth(context),
          ),
          child: Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.allBookings.isEmpty) {
                      return Center(
                        child: LoadingWidget(
                          message: l10n.carregandoAgendamentos,
                        ),
                      );
                    }

                    final bookings = _statusFilter == null
                        ? provider.allBookings
                        : provider.allBookings
                              .where((b) => b.status == _statusFilter)
                              .toList();

                    if (bookings.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () => provider.loadAllBookings(),
                      color: AppColors.gold,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            _buildBookingCard(bookings[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final filters = <(String, BookingStatus?)>[
      (l10n.todos, null),
      (l10n.pendente, BookingStatus.pending),
      (l10n.confirmada, BookingStatus.confirmed),
      (l10n.concluida, BookingStatus.completed),
      (l10n.cancelada, BookingStatus.cancelled),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.borderStrong)),
      ),
      // Altura intrínseca (sem fixa) — evita corte vertical de chips com
      // fontes grandes do sistema.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  final (label, status) = filters[i];
                  final isSelected = _statusFilter == status;
                  return GestureDetector(
                    onTap: () => setState(() => _statusFilter = status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.navy : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.navy
                              : palette.textMuted,
                        ),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : palette.textBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _targetLabel(l10n, booking),
                    style: AppTextStyles.bodyMediumBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.person_outline,
              booking.userName.isEmpty ? l10n.naoInformado : booking.userName,
            ),
            if (booking.userPhone.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildInfoRow(Icons.phone_outlined, booking.userPhone),
            ],
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.event_outlined,
              '${_formatDate(booking.date)} · ${booking.time}',
            ),
            if (booking.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildInfoRow(Icons.notes_rounded, booking.notes),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (booking.status == BookingStatus.pending)
                  _buildAction(
                    icon: Icons.check_circle_outline,
                    label: l10n.confirmar,
                    color: AppColors.success,
                    onTap: () =>
                        _updateStatus(booking, BookingStatus.confirmed),
                  ),
                if (booking.status == BookingStatus.confirmed)
                  _buildAction(
                    icon: Icons.task_alt_rounded,
                    label: l10n.concluir,
                    color: AppColors.info,
                    onTap: () =>
                        _updateStatus(booking, BookingStatus.completed),
                  ),
                if (booking.status == BookingStatus.pending ||
                    booking.status == BookingStatus.confirmed)
                  _buildAction(
                    icon: Icons.cancel_outlined,
                    label: l10n.cancelar,
                    color: AppColors.error,
                    onTap: () =>
                        _updateStatus(booking, BookingStatus.cancelled),
                  ),
                if (booking.userPhone.isNotEmpty)
                  _buildAction(
                    icon: Icons.chat_bubble_outline,
                    label: l10n.falarWhatsapp,
                    color: AppColors.whatsapp,
                    onTap: () => _openWhatsApp(booking),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: palette.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: palette.textBody),
          ),
        ),
      ],
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      BookingStatus.pending => (l10n.pendente, AppColors.gold),
      BookingStatus.confirmed => (l10n.confirmada, AppColors.success),
      BookingStatus.cancelled => (l10n.cancelada, AppColors.error),
      BookingStatus.completed => (l10n.concluida, AppColors.info),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildEmptyState() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
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
                Icons.calendar_today_outlined,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.semAgendamentos,
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.seuProximoAgendamento,
              style: AppTextStyles.bodyMedium.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
