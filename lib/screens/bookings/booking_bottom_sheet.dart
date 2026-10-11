import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/whatsapp_util.dart';
import '../../l10n/app_localizations.dart';

enum _BookingStep { schedule, success }

class BookingBottomSheet extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final bool isLand;

  const BookingBottomSheet({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    this.isLand = false,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final _notesController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  _BookingStep _step = _BookingStep.schedule;
  bool _isSubmitting = false;

  bool get _isGuest => context.read<AuthProvider>().user == null;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final palette = context.palette;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('pt'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.gold,
              onPrimary: AppColors.white,
              surface: palette.surface,
              onSurface: palette.textTitle,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final palette = context.palette;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.gold,
              onPrimary: AppColors.white,
              surface: palette.surface,
              onSurface: palette.textTitle,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final guest = auth.user == null;
    final name = guest ? _nameController.text.trim() : (auth.user?.name ?? '');
    final phone = guest
        ? _phoneController.text.trim()
        : (auth.user?.phone ?? '');

    setState(() => _isSubmitting = true);

    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final booking = BookingModel(
      id: '',
      propertyId: widget.isLand ? '' : widget.propertyId,
      landId: widget.isLand ? widget.propertyId : null,
      userId: guest ? null : auth.user?.id,
      userName: name,
      userPhone: phone,
      date: _selectedDate,
      time: timeStr,
      status: BookingStatus.pending,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final provider = context.read<BookingProvider>();
    final created = await provider.createBooking(booking);

    if (!mounted) return;

    if (created == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.erroCriarAgendamento),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (guest) {
      await provider.registerGuestClient(
        name: name,
        phone: phone,
        bookingId: created.id,
      );
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _step = _BookingStep.success;
    });
  }

  String get _whatsappMessage {
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (context.read<AuthProvider>().user?.name ?? '');
    return 'Olá! Agendei uma visita pelo app.\n'
        '${widget.isLand ? 'Terreno' : 'Imóvel'}: ${widget.propertyTitle}\n'
        'Data: $dateStr\n'
        'Hora: $timeStr\n'
        'Nome: $name';
  }

  Future<void> _openWhatsApp() async {
    await WhatsAppUtil.open(message: _whatsappMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SingleChildScrollView(
        child: _step == _BookingStep.schedule
            ? _buildScheduleStep()
            : _buildSuccessStep(),
      ),
    );
  }

  Widget _buildScheduleStep() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final guest = _isGuest;
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 20),
          Text(l10n.agendarVisita, style: AppTextStyles.h6),
          const SizedBox(height: 4),
          Text(
            widget.propertyTitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: palette.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          if (guest) ...[
            _buildFieldLabel(l10n.nomeCompleto),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              style: AppTextStyles.bodyMedium,
              decoration: _inputDecoration(
                hint: l10n.oSeuNome,
                icon: Icons.person_outline,
              ),
              validator: (value) => Validators.minLength(
                value,
                3,
                customMessage: l10n.insiraNome,
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 16),
            _buildFieldLabel(l10n.telefone),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.bodyMedium,
              decoration: _inputDecoration(
                hint: '(9XX) XXX XXX',
                icon: Icons.phone_outlined,
              ),
              validator: (value) => Validators.phone(value, l10n: l10n),
            ),
            const SizedBox(height: 16),
          ],
          _buildFieldLabel(l10n.data),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: palette.borderStrong),
                borderRadius: BorderRadius.circular(12),
                color: palette.background,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 12),
                  Text(dateStr, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(l10n.horario),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: palette.borderStrong),
                borderRadius: BorderRadius.circular(12),
                color: palette.background,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 12),
                  Text(timeStr, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(l10n.observacoes),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            enabled: !_isSubmitting,
            style: AppTextStyles.bodyMedium,
            decoration: _inputDecoration(
              hint: l10n.exPrefiroManha,
              multiline: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppColors.gold.withValues(alpha: 0.4),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      l10n.confirmarAgendamento,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDragHandle(),
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.agendamentoSolicitado,
          style: AppTextStyles.h5,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.propertyTitle}\n$dateStr · $timeStr',
          style: AppTextStyles.bodyMedium.copyWith(
            color: palette.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _openWhatsApp,
            icon: const Icon(Icons.chat_bubble_outline, size: 20),
            label: Text(
              l10n.falarWhatsapp,
              style: AppTextStyles.buttonLarge.copyWith(
                color: AppColors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.whatsapp,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: AppColors.whatsapp.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.concluir,
            style: AppTextStyles.buttonMedium.copyWith(
              color: palette.textBody,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
    bool multiline = false,
  }) {
    final palette = context.palette;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.borderStrong),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: palette.textMuted),
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: AppColors.gold)
          : null,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      filled: true,
      fillColor: palette.background,
      contentPadding: const EdgeInsets.all(14),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.palette.textMuted,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.bodyMediumBold.copyWith(
        color: context.palette.textTitle,
      ),
    );
  }
}
