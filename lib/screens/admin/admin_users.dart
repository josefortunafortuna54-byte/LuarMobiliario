import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/user_model.dart';
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
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _allUsers = _mockUsers;
      _filterUsers();
      _isLoading = false;
    });
  }

  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers
          .where((u) =>
              u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.email.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
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
          'Utilizadores',
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
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredUsers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.white,
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
          hintText: 'Pesquisar utilizadores...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.gray400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.search_rounded, size: 22, color: AppColors.gray400),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _filterUsers();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.close_rounded, size: 18, color: AppColors.gray400),
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.gray50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gray200),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${_filteredUsers.length} utilizador${_filteredUsers.length != 1 ? 'es' : ''}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
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
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
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
                        color: AppColors.gray500,
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
                color: AppColors.gray300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final (label, color) = switch (role) {
      UserRole.admin => ('Admin', AppColors.error),
      UserRole.agent => ('Agente', AppColors.gold),
      UserRole.client => ('Cliente', AppColors.info),
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
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: 9,
        ),
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
              'Sem resultados',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Nenhum utilizador encontrado para "$_searchQuery"'
                  : 'Nenhum utilizador registado.',
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

class _UserDetailSheet extends StatelessWidget {
  const _UserDetailSheet({required this.user});

  final UserModel user;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final (roleLabel, roleColor) = switch (user.role) {
      UserRole.admin => ('Administrador', AppColors.error),
      UserRole.agent => ('Agente Imobiliário', AppColors.gold),
      UserRole.client => ('Cliente', AppColors.info),
    };

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          AvatarWidget(
            imageUrl: user.avatarUrl,
            name: user.name,
            size: AvatarSize.large,
            borderColor: AppColors.gold,
          ),
          const SizedBox(height: 16),
          Text(user.name, style: AppTextStyles.h5),
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
            label: 'Email',
            value: user.email,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Telefone',
            value: user.phone.isNotEmpty ? user.phone : 'Não informado',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Registado em',
            value: _formatDate(user.createdAt),
          ),
          const SizedBox(height: 24),
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
                'Fechar',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gray50,
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
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMediumBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final List<UserModel> _mockUsers = [
  UserModel(
    id: '1',
    name: 'Carlos Mendes',
    email: 'carlos.mendes@email.com',
    phone: '+244 923 000 001',
    avatarUrl: '',
    role: UserRole.client,
    createdAt: DateTime(2024, 3, 15),
    updatedAt: DateTime(2024, 3, 15),
  ),
  UserModel(
    id: '2',
    name: 'Ana Ferreira',
    email: 'ana.ferreira@email.com',
    phone: '+244 923 000 002',
    avatarUrl: '',
    role: UserRole.agent,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 1, 10),
  ),
  UserModel(
    id: '3',
    name: 'Pedro Santos',
    email: 'pedro.santos@email.com',
    phone: '+244 923 000 003',
    avatarUrl: '',
    role: UserRole.client,
    createdAt: DateTime(2024, 5, 22),
    updatedAt: DateTime(2024, 5, 22),
  ),
  UserModel(
    id: '4',
    name: 'Maria João',
    email: 'maria.joao@email.com',
    phone: '+244 923 000 004',
    avatarUrl: '',
    role: UserRole.admin,
    createdAt: DateTime(2023, 12, 1),
    updatedAt: DateTime(2024, 6, 10),
  ),
  UserModel(
    id: '5',
    name: 'Ricardo Almeida',
    email: 'ricardo.almeida@email.com',
    phone: '+244 923 000 005',
    avatarUrl: '',
    role: UserRole.client,
    createdAt: DateTime(2024, 2, 8),
    updatedAt: DateTime(2024, 2, 8),
  ),
  UserModel(
    id: '6',
    name: 'Sofia Costa',
    email: 'sofia.costa@email.com',
    phone: '+244 923 000 006',
    avatarUrl: '',
    role: UserRole.agent,
    createdAt: DateTime(2024, 4, 3),
    updatedAt: DateTime(2024, 4, 3),
  ),
];
