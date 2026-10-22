import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../providers/favorite_provider.dart';

/// Alterna um favorito e avisa o utilizador quando a operação falha.
///
/// Sem este helper cada ecrã repetia o `ScaffoldMessenger` por conta própria e
/// alguns ignoravam o resultado — o coração "não funcionava" e não havia
/// qualquer indicação do erro.
Future<FavoriteToggleResult> toggleFavoriteWithFeedback(
  BuildContext context,
  FavoriteProvider provider,
  String userId, {
  String? propertyId,
  String? landId,
}) async {
  final result = await provider.toggleFavorite(
    userId,
    propertyId: propertyId,
    landId: landId,
  );

  if (result == FavoriteToggleResult.failed && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).erroAoGuardarFavorito),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  return result;
}
