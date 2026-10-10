import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/booking_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';

enum _BookingStep { schedule, register }

class BookingBottomSheet extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const BookingBottomSheet({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final _notesController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  _BookingStep _step = _BookingStep.schedule;
  String? _bookingId;
  bool _isSubmitting = false;

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
    final userId = auth.user?.id;
    final userName = guest ? '' : (auth.user?.name ?? '');
    final userPhone = guest ? '' : (auth.user?.phone ?? '');

    setState(() => _isSubmitting = true);

    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final booking = BookingModel(
      id: '',
      propertyId: widget.propertyId,
      userId: guest ? null : userId,
      userName: userName,
      userPhone: userPhone,
      date: _selectedDate,
      time: timeStr,
      status: BookingStatus.pending,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final created = await context.read<BookingProvider>().createBooking(
      booking,
    );

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
      setState(() {
        _bookingId = created.id;
        _step = _BookingStep.register;
        _isSubmitting = false;
      });
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.agendamentoSolicitado),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _submitRegistration() async {
    final l10n = AppLocalizations.of(context);
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await context.read<BookingProvider>().registerGuestClient(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      bookingId: _bookingId ?? '',
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.agendamentoRegistado),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.erroRegistarDados),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
            : _buildRegisterStep(),
      ),
    );
  }

  Widget _buildScheduleStep() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
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
            decoration: InputDecoration(
              hintText: l10n.exPrefiroManha,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: palette.textMuted,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
              filled: true,
              fillColor: palette.background,
              contentPadding: const EdgeInsets.all(14),
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

  Widget _buildRegisterStep() {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 22,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.agendamentoSolicitado,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.completeRegisto, style: AppTextStyles.h6),
          const SizedBox(height: 4),
          Text(
            l10n.indiqueNomeTelefone,
            style: AppTextStyles.bodySmall.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              labelText: l10n.nomeCompleto,
              hintText: l10n.oSeuNome,
              prefixIcon: const Icon(
                Icons.person_outline,
                size: 20,
                color: AppColors.gold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
              filled: true,
              fillColor: palette.background,
              contentPadding: const EdgeInsets.all(14),
            ),
            validator: (value) => Validators.minLength(
              value,
              3,
              customMessage: l10n.insiraNome,
              l10n: l10n,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              labelText: l10n.telefone,
              hintText: '(00) 00000-0000',
              prefixIcon: const Icon(
                Icons.phone_outlined,
                size: 20,
                color: AppColors.gold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
              filled: true,
              fillColor: palette.background,
              contentPadding: const EdgeInsets.all(14),
            ),
            validator: (value) => Validators.phone(value, l10n: l10n),
            onFieldSubmitted: (_) => _submitRegistration(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRegistration,
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
                      l10n.concluirRegisto,
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
