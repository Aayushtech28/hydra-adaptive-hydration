import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import 'widgets.dart';

/// Returns true when the user has Pro; otherwise opens the paywall and
/// returns false. Free features never call this.
bool ensurePro(BuildContext context, WidgetRef ref) {
  if (ref.read(isProProvider)) return true;
  context.push('/pro');
  return false;
}

/// Inline "this is Pro" card used instead of a hard wall on a screen.
class ProUpsell extends StatelessWidget {
  const ProUpsell({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return HCard(
      color: context.hx.accentSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: context.hx.accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l.paywallTitle,
                  style: context.text.labelLarge?.copyWith(
                    color: context.hx.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(message, style: context.text.bodyMedium),
          const SizedBox(height: Gap.md),
          FilledButton(
            onPressed: () => context.push('/pro'),
            child: Text(l.healthProCta),
          ),
        ],
      ),
    );
  }
}
