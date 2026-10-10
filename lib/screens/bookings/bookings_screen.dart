import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/loading_widget.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;
    if (userId == null) return;
    await context.read<BookingProvider>().loadBookings(userId);
  }

  String _shortPropertyId(AppLocalizations l10n, String id) {
    if (id.isEmpty) return l10n.imovel;
    if (id.length > 8) return id.substring(0, 8);
    return id;
  }

  Future<void> _onRefresh() async {
    await _loadBookings();
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.cancelarAgendamento, style: AppTextStyles.h6),
        content: Text(
          l10n.desejaCancelarAgendamento(
            booking.propertyTitle.isNotEmpty
                ? booking.propertyTitle
                : _shortPropertyId(l10n, booking.propertyId),
          ),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.nao,
              style: AppTextStyles.buttonMedium.copyWith(
                color: palette.textBody,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.simCancelar,
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<BookingProvider>().cancelBooking(booking.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final isGuest = context.watch<AuthProvider>().user == null;

    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.agendamentos,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        bottom: isGuest
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: AppColors.gold,
                indicatorWeight: 3,
                labelColor: AppColors.gold,
                unselectedLabelColor: palette.textMuted,
                labelStyle: AppTextStyles.labelLarge,
                unselectedLabelStyle: AppTextStyles.labelLarge,
                tabs: [
                  Tab(text: l10n.proximas),
                  Tab(text: l10n.historico),
                ],
              ),
      ),
      body: isGuest
          ? _buildGuestState()
          : Consumer<BookingProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(
                    child: LoadingWidget(message: l10n.carregandoAgendamentos),
                  );
                }

                if (provider.error != null) {
                  return _buildErrorState(provider.error!);
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingTab(provider),
                    _buildHistoryTab(provider),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildGuestState() {
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
              l10n.osSeusAgendamentos,
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.quandoAgenda,
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

  Widget _buildUpcomingTab(BookingProvider provider) {
    final l10n = AppLocalizations.of(context);
    final upcoming = provider.upcomingBookings;
    if (upcoming.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_outlined,
        title: l10n.semAgendamentos,
        subtitle: l10n.seuProximoAgendamento,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.gold,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: upcoming.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = upcoming[index];
          return _buildBookingCard(
            booking: booking,
            showCancel: booking.status == BookingStatus.pending,
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab(BookingProvider provider) {
    final l10n = AppLocalizations.of(context);
    final history = provider.historyBookings;
    if (history.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: l10n.semHistorico,
        subtitle: l10n.agendamentosAnteriores,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.gold,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = history[index];
          return _buildBookingCard(booking: booking, showCancel: false);
        },
      ),
    );
  }

  Widget _buildBookingCard({
    required BookingModel booking,
    required bool showCancel,
  }) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final formattedDate =
        '${booking.date.day.toString().padLeft(2, '0')}/${booking.date.month.toString().padLeft(2, '0')}/${booking.date.year}';

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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.propertyTitle.isNotEmpty
                            ? booking.propertyTitle
                            : l10n.imovelCurto(
                                _shortPropertyId(l10n, booking.propertyId),
                              ),
                        style: AppTextStyles.bodyMediumBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.agendadoPor(booking.userName),
                        style: AppTextStyles.bodyTiny.copyWith(
                          color: palette.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: palette.textTitle,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textBody,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: palette.textTitle,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: palette.textBody,
                    ),
                  ),
                  const Spacer(),
                  if (booking.notes.isNotEmpty)
                    Icon(
                      Icons.notes_rounded,
                      size: 16,
                      color: palette.textMuted,
                    ),
                ],
              ),
            ),
            if (showCancel) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelBooking(booking),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: Text(
                    l10n.cancelarAgendamento,
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
                icon,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTextStyles.h5, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.erroAoCarregar,
              style: AppTextStyles.h6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _loadBookings,
              child: Text(
                l10n.tentarNovamente,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
