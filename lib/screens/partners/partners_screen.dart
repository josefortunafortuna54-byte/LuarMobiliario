import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/partner_model.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/partner_provider.dart';
import '../../core/utils/routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

String partnerBusinessTypeLabel(PartnerBusinessType type) {
  switch (type) {
    case PartnerBusinessType.imobiliaria:
      return 'Imobiliária';
    case PartnerBusinessType.construtora:
      return 'Construtora';
    case PartnerBusinessType.corretor:
      return 'Corretor';
    case PartnerBusinessType.administrador:
      return 'Administrador';
    case PartnerBusinessType.outro:
      return 'Outro';
  }
}

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPartners();
    });
  }

  Future<void> _loadPartners() async {
    await context.read<PartnerProvider>().loadAll();
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;
    if (userId != null) {
      await context.read<PartnerProvider>().loadMine(userId);
    }
  }

  bool get _canManage {
    final role = context.read<AuthProvider>().user?.role;
    return role == UserRole.agent || role == UserRole.admin;
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
          'Parceiros',
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        actions: [
          if (_canManage)
            IconButton(
              tooltip: 'Meu perfil de parceiro',
              icon: const Icon(Icons.badge_outlined),
              onPressed: () => _openPartnerForm(context),
            ),
        ],
      ),
      floatingActionButton: _canManage
          ? FloatingActionButton.extended(
              onPressed: () => _openPartnerForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Meu Perfil'),
            )
          : null,
      body: Consumer<PartnerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.partners.isEmpty) {
            return const LoadingWidget(message: 'Carregando parceiros...');
          }

          if (provider.error != null && provider.partners.isEmpty) {
            return _buildErrorState(provider.error!);
          }

          if (provider.partners.isEmpty) {
            return EmptyState(
              icon: Icons.handshake_outlined,
              title: 'Nenhum parceiro encontrado',
              subtitle: 'Os parceiros da Luar Mobiliário aparecerão aqui.',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadPartners,
            color: AppColors.gold,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.partners.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildPartnerCard(provider.partners[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPartners,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(PartnerModel partner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.handshake_outlined,
              size: 24,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.companyName.isNotEmpty
                      ? partner.companyName
                      : 'Parceiro',
                  style: AppTextStyles.bodyMediumBold,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildChip(partnerBusinessTypeLabel(partner.businessType)),
                    if (partner.nif.isNotEmpty)
                      _buildChip('NIF: ${partner.nif}'),
                  ],
                ),
                if (partner.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.place_outlined, partner.address),
                ],
                if (partner.whatsapp.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.chat_bubble_outline_rounded,
                      'WhatsApp: ${partner.whatsapp}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyTiny.copyWith(color: AppColors.navy),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _openPartnerForm(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.partnerForm);
  }
}