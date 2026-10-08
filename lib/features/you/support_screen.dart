import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../application/diagnostics.dart';
import '../../core/config/app_config.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/analytics/analytics_service.dart';
import '../common/widgets.dart';
import 'privacy_screen.dart' show openUrl;

final _versionProvider = FutureProvider<String>((ref) async {
  try {
    final i = await PackageInfo.fromPlatform();
    return '${i.version}+${i.buildNumber}';
  } catch (_) {
    return 'dev';
  }
});

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});
  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  String? _rating;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final version = ref.watch(_versionProvider).value ?? '…';
    final svc = ref.watch(servicesProvider);

    Widget face(String key, String emoji, String label) => Semantics(
          button: true,
          selected: _rating == key,
          label: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(Radii.md),
            onTap: () {
              setState(() => _rating = key);
              svc.analytics.log(AnalyticsEvent.feedbackGiven, {'rating': key});
            },
            child: Container(
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: Gap.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: _rating == key ? context.hx.accent : context.hx.hairline),
              ),
              child: Column(children: [
                ExcludeSemantics(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                const SizedBox(height: 4),
                Text(label, style: context.text.labelSmall, textAlign: TextAlign.center),
              ]),
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.supportTitle)),
      body: SafeArea(
        child: PageBody(children: [
          TileGroup(children: [
            HTile(leading: Icons.notifications_active_outlined, title: l.supportFaqNotifTitle, subtitle: l.supportFaqNotifBody, onTap: () => context.push('/you/notifications/help')),
            HTile(leading: Icons.favorite_border, title: l.supportFaqHealthTitle, subtitle: l.supportFaqHealthBody, onTap: () => context.push('/you/health')),
            HTile(leading: Icons.restore, title: l.supportFaqRestoreTitle, subtitle: l.supportFaqRestoreBody, onTap: () => context.push('/pro')),
          ]),
          SectionHeader(l.supportFeedbackTitle),
          Wrap(spacing: 8, runSpacing: 8, children: [
            face('love', '❤️', l.supportFeedbackLove),
            face('good', '🙂', l.supportFeedbackGood),
            face('okay', '😐', l.supportFeedbackOkay),
            face('not_useful', '😕', l.supportFeedbackNot),
          ]),
          if (_rating != null)
            Padding(
              padding: const EdgeInsets.only(top: Gap.md),
              child: _rating == 'not_useful' || _rating == 'okay'
                  ? TextButton(
                      onPressed: () => openUrl(context, 'mailto:${AppConfig.supportEmail}?subject=HYDRA%20feedback'),
                      child: Text(l.supportFeedbackFix),
                    )
                  : Text(l.supportFeedbackThanks, style: context.text.bodyMedium),
            ),
          SectionHeader(l.supportContact),
          TileGroup(children: [
            HTile(leading: Icons.mail_outline, title: l.supportContact, subtitle: AppConfig.supportEmail, onTap: () => openUrl(context, 'mailto:${AppConfig.supportEmail}')),
            HTile(
              leading: Icons.copy_all_outlined,
              title: l.supportCopyDiagnostics,
              onTap: () async {
                final report = await buildDiagnosticsReport(svc, version: version);
                await Clipboard.setData(ClipboardData(text: report));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.supportDiagnosticsCopied)));
              },
            ),
            HTile(leading: Icons.article_outlined, title: l.supportLicenses, onTap: () => showLicensePage(context: context, applicationName: l.appName, applicationVersion: version)),
          ]),
          const SizedBox(height: Gap.xl),
          Text(l.supportAbout, style: context.text.titleSmall),
          Text(l.supportVersion(version), style: context.text.bodySmall),
          const SizedBox(height: Gap.sm),
          Text(l.disclaimerShort, style: context.text.bodySmall),
        ]),
      ),
    );
  }
}
