import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/providers/locale_provider.dart';
import '../core/providers/playback_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/theme/app_palette.dart';
import '../l10n/app_localizations.dart';

Future<void> showSettingsSheet(BuildContext context) async {
  final themeProvider = context.read<ThemeProvider>();
  final localeProvider = context.read<LocaleProvider>();
  final playbackProvider = context.read<PlaybackProvider>();
  final l10n = AppLocalizations.of(context);

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final palette = ctx.palette;
      final localeCode = localeProvider.locale.languageCode;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(label: l10n.aparencia, palette: palette),
              _ChoiceTile(
                label: l10n.temaSistema,
                selected: themeProvider.preference == ThemePreference.system,
                palette: palette,
                onTap: () {
                  themeProvider.setPreference(ThemePreference.system);
                  Navigator.pop(ctx);
                },
              ),
              _ChoiceTile(
                label: l10n.temaClaro,
                selected: themeProvider.preference == ThemePreference.light,
                palette: palette,
                onTap: () {
                  themeProvider.setPreference(ThemePreference.light);
                  Navigator.pop(ctx);
                },
              ),
              _ChoiceTile(
                label: l10n.temaEscuro,
                selected: themeProvider.preference == ThemePreference.dark,
                palette: palette,
                onTap: () {
                  themeProvider.setPreference(ThemePreference.dark);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              _SectionHeader(label: l10n.idioma, palette: palette),
              _ChoiceTile(
                label: l10n.portugues,
                selected: localeCode == 'pt',
                palette: palette,
                onTap: () {
                  localeProvider.setLocale(const Locale('pt'));
                  Navigator.pop(ctx);
                },
              ),
              _ChoiceTile(
                label: l10n.ingles,
                selected: localeCode == 'en',
                palette: palette,
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              _SectionHeader(label: l10n.videos, palette: palette),
              SwitchListTile(
                title: Text(
                  l10n.reproducaoAutomatica,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: palette.textBody,
                  ),
                ),
                subtitle: Text(
                  l10n.reproducaoAutomaticaDesc,
                  style: AppTextStyles.bodyTiny.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                value: playbackProvider.autoplay,
                activeThumbColor: AppColors.gold,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                onChanged: (value) {
                  playbackProvider.setAutoplay(value);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.palette});

  final String label;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: palette.textMuted),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: palette.textBody),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.gold)
          : null,
      onTap: onTap,
    );
  }
}
