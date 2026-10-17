import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/avatar_widget.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserModel> _filteredUsers = [];
  List<UserModel> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user?.role != UserRole.admin && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).acessoRestritoAdmin),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    });
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final admin = context.read<AdminProvider>();
    await admin.loadUsers();
    if (!mounted) return;
    setState(() {
      _allUsers = admin.allUsers;
      _filterUsers();
      _isLoading = false;
    });
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers
          .where(
            (u) =>
                u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                u.email.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: palette.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.utilizadores,
          style: AppTextStyles.h6.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildUserCount(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  )
                : _filteredUsers.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    color: AppColors.gold,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredUsers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserTile(user);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: palette.surface,
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterUsers();
          });
        },
        decoration: InputDecoration(
          hintText: l10n.pesquisarUtilizadores,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: palette.textMuted,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: palette.textMuted,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _filterUsers();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: palette.textMuted,
                    ),
                  ),
                )
              : null,
          filled: true,
          fillColor: palette.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: palette.borderStrong),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCount() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            l10n.contarUtilizadores(_filteredUsers.length),
            style: AppTextStyles.bodySmall.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(16),
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        splashColor: AppColors.gold.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              AvatarWidget(
                imageUrl: user.avatarUrl,
                name: user.name,
                size: AvatarSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.bodyMediumBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: AppTextStyles.bodyTiny.copyWith(
                        color: palette.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildRoleBadge(user.role),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: palette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = switch (role) {
      UserRole.admin => (l10n.admin, AppColors.error),
      UserRole.agent => (l10n.agente, AppColors.gold),
      UserRole.client => (l10n.cliente, AppColors.info),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 9),
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserDetailSheet(user: user),
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
                Icons.people_outline_rounded,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.semResultados,
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n.nenhumUtilizadorBusca(_searchQuery)
                  : l10n.nenhumUtilizador,
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

class _UserDetailSheet extends StatefulWidget {
  const _UserDetailSheet({required this.user});

  final UserModel user;

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  late UserRole _selectedRole;
  late bool _isVerified;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    _isVerified = widget.user.verified;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final (roleLabel, roleColor) = switch (widget.user.role) {
      UserRole.admin => (l10n.administrador, AppColors.error),
      UserRole.agent => (l10n.agenteImobiliario, AppColors.gold),
      UserRole.client => (l10n.cliente, AppColors.info),
    };

    final isCurrentUser =
        context.read<AuthProvider>().user?.id == widget.user.id;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            AvatarWidget(
              imageUrl: widget.user.avatarUrl,
              name: widget.user.name,
              size: AvatarSize.large,
              borderColor: AppColors.gold,
            ),
            const SizedBox(height: 16),
            Text(widget.user.name, style: AppTextStyles.h5),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: roleColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                roleLabel,
                style: AppTextStyles.labelMedium.copyWith(color: roleColor),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              icon: Icons.email_outlined,
              label: l10n.email,
              value: widget.user.email,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: l10n.telefone,
              value: widget.user.phone.isNotEmpty
                  ? widget.user.phone
                  : l10n.naoInformado,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.registadoEm,
              value: _formatDate(widget.user.createdAt),
            ),
            const SizedBox(height: 20),

            if (!isCurrentUser) ...[
              _buildRoleSection(),
              if (widget.user.role == UserRole.agent) ...[
                const SizedBox(height: 16),
                _buildVerificationSection(),
              ],
              const SizedBox(height: 16),
              _buildDeleteSection(),
            ],

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.fechar,
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: palette.textBody,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 20,
                color: AppColors.gold,
              ),
              const SizedBox(width: 10),
              Text(l10n.funcao, style: AppTextStyles.bodyMediumBold),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
              filled: true,
              fillColor: palette.inputFill,
            ),
            items: [
              DropdownMenuItem(
                value: UserRole.client,
                child: Text(l10n.cliente),
              ),
              DropdownMenuItem(value: UserRole.agent, child: Text(l10n.agente)),
              DropdownMenuItem(
                value: UserRole.admin,
                child: Text(l10n.administrador),
              ),
            ],
            onChanged: _isUpdating
                ? null
                : (value) {
                    if (value != null && value != _selectedRole) {
                      _confirmRoleChange(value);
                    }
                  },
          ),
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final color = _isVerified ? AppColors.info : palette.textMuted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isVerified
            ? AppColors.info.withValues(alpha: 0.04)
            : palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isVerified
              ? AppColors.info.withValues(alpha: 0.25)
              : palette.borderStrong,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isVerified
                ? Icons.verified_user_rounded
                : Icons.help_outline_rounded,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isVerified
                      ? l10n.anuncianteVerificado
                      : l10n.verificarAnunciante,
                  style: AppTextStyles.bodyMediumBold,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.user.email,
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _isUpdating ? null : () => _toggleVerification(),
            style: TextButton.styleFrom(
              foregroundColor: _isVerified ? AppColors.error : AppColors.info,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _isVerified ? l10n.retirarVerificacao : l10n.verificarAnunciante,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVerification() async {
    final l10n = AppLocalizations.of(context);
    final actorId = context.read<AuthProvider>().user?.id;
    if (actorId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _isVerified ? l10n.retirarVerificacao : l10n.verificarAnunciante,
        ),
        content: Text(l10n.temCertezaRemover(widget.user.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(l10n.confirmar),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUpdating = true);
    final admin = context.read<AdminProvider>();
    final newVerified = !_isVerified;
    final success = await admin.setUserVerified(
      userId: widget.user.id,
      verified: newVerified,
      actorId: actorId,
    );

    if (!mounted) return;
    setState(() {
      _isUpdating = false;
      if (success) _isVerified = newVerified;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.verificacaoAlterada : l10n.erroVerificacao),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  Widget _buildDeleteSection() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.removerUtilizador,
                  style: AppTextStyles.bodyMediumBold,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.acaoIrreversivel,
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _isUpdating ? null : _confirmDelete,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.remover),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRoleChange(UserRole newRole) async {
    final l10n = AppLocalizations.of(context);
    final (newLabel, newColor) = switch (newRole) {
      UserRole.admin => (l10n.administrador, AppColors.error),
      UserRole.agent => (l10n.agenteImobiliario, AppColors.gold),
      UserRole.client => (l10n.cliente, AppColors.info),
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.alterarFuncao),
        content: Text(l10n.alterarFuncaoDe(widget.user.name, newLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(l10n.confirmar),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUpdating = true);
    final admin = context.read<AdminProvider>();
    final success = await admin.updateUserRole(widget.user.id, newRole);

    if (!mounted) return;
    setState(() {
      _isUpdating = false;
      if (success) _selectedRole = newRole;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.funcaoAlterada(newLabel)),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.erroAlterarFuncao),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removerUtilizador),
        content: Text(l10n.temCertezaRemover(widget.user.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.remover),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUpdating = true);
    final admin = context.read<AdminProvider>();
    final success = await admin.deleteUser(widget.user.id);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.utilizadorRemovido),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.erroRemoverUtilizador),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMediumBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
