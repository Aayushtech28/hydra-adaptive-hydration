import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/config/app_config.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/purchase/entitlement.dart';
import '../../services/purchase/subscription_service.dart';
import '../common/widgets.dart';
import 'privacy_screen.dart' show openUrl;

final _plansProvider = FutureProvider.autoDispose<List<ProPlan>>(
    (ref) => ref.watch(servicesProvider).subscription.plans());

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});
  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  ProPeriod _selected = ProPeriod.annual;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(servicesProvider).analytics.log(AnalyticsEvent.paywallViewed);
  }

  Future<void> _buy(ProPlan plan) async {
    final l = AppLocalizations.of(context);
    final svc = ref.read(servicesProvider);
    setState(() => _busy = true);
    final r = await svc.subscription.purchase(plan);
    if (!mounted) return;
    setState(() => _busy = false);
    final msg = switch (r) {
      PurchaseOutcome.success => l.paywallPurchased,
      PurchaseOutcome.cancelled => l.paywallCancelled,
      PurchaseOutcome.pending => l.paywallPending,
      PurchaseOutcome.failed => l.paywallFailed,
      PurchaseOutcome.unavailable => l.paywallUnavailableBody,
    };
    if (r == PurchaseOutcome.success) {
      svc.analytics.log(AnalyticsEvent.premiumStarted, {'plan': plan.period.name});
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    if (r == PurchaseOutcome.success && context.canPop()) context.pop();
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context);
    final svc = ref.read(servicesProvider);
    setState(() => _busy = true);
    final r = await svc.subscription.restore();
    if (!mounted) return;
    setState(() => _busy = false);
    if (r == PurchaseOutcome.success) svc.analytics.log(AnalyticsEvent.premiumRestored);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(r == PurchaseOutcome.success
          ? l.paywallRestored
          : r == PurchaseOutcome.unavailable
              ? l.paywallUnavailableBody
              : l.paywallRestoreNone),
    ));
  }

  String get _manageUrl => defaultTargetPlatform == TargetPlatform.iOS
      ? 'https://apps.apple.com/account/subscriptions'
      : 'https://play.google.com/store/account/subscriptions';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.hx;
    final ent = ref.watch(entitlementProvider).value ?? Entitlement.free;
    final isPro = ref.watch(isProProvider);
    final plans = ref.watch(_plansProvider).value;
    final loading = ref.watch(_plansProvider).isLoading;

    final benefits = [
      l.paywallBenefitNoAds, l.paywallBenefitScheduler, l.paywallBenefitHealth, l.paywallBenefitInsights,
      l.paywallBenefitVessels, l.paywallBenefitRoutines, l.paywallBenefitTravel, l.paywallBenefitWidgets,
      l.paywallBenefitExport, l.paywallBenefitThemes,
    ];

    String periodName(ProPeriod p) => switch (p) {
          ProPeriod.annual => l.paywallAnnual,
          ProPeriod.monthly => l.paywallMonthly,
          ProPeriod.lifetime => l.paywallLifetime,
        };

    final selectedPlan = plans?.where((p) => p.period == _selected).firstOrNull ?? plans?.firstOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), tooltip: l.commonClose, onPressed: () => context.canPop() ? context.pop() : context.go('/home')),
      ),
      body: SafeArea(
        child: PageBody(children: [
          Text(l.paywallTitle, style: context.text.labelLarge?.copyWith(color: t.accent, letterSpacing: 3)),
          const SizedBox(height: Gap.sm),
          Semantics(header: true, child: Text(l.paywallHeadline, style: context.text.headlineMedium)),
          const SizedBox(height: Gap.xl),
          for (final b in benefits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                Text('✓', style: context.text.titleMedium?.copyWith(color: t.good)),
                const SizedBox(width: Gap.md),
                Expanded(child: Text(b, style: context.text.bodyLarge)),
              ]),
            ),
          const SizedBox(height: Gap.md),
          Text(l.paywallFreeNote, style: context.text.bodyMedium?.copyWith(color: t.inkMuted)),
          const SizedBox(height: Gap.xl),
          if (isPro) ...[
            HCard(
              color: t.accentSoft,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.paywallActiveTitle, style: context.text.titleMedium),
                if (ent.needsBillingAttention)
                  Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.paywallBillingIssue, style: context.text.bodyMedium)),
              ]),
            ),
          ] else if (loading)
            const SkeletonBox(height: 140)
          else if (plans == null || plans.isEmpty)
            ErrorNotice(
              title: l.paywallUnavailableTitle,
              message: l.paywallUnavailableBody,
              primaryLabel: l.commonTryAgain,
              onPrimary: () => ref.invalidate(_plansProvider),
            )
          else ...[
            for (final p in plans)
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.sm),
                child: Semantics(
                  selected: selectedPlan?.period == p.period,
                  inMutuallyExclusiveGroup: true,
                  button: true,
                  child: HCard(
                    onTap: () => setState(() => _selected = p.period),
                    color: selectedPlan?.period == p.period ? t.accentSoft : t.surface,
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(periodName(p.period), style: context.text.titleMedium),
                            if (p.period == ProPeriod.annual) ...[
                              const SizedBox(width: 8),
                              StatusChip(kind: StatusKind.good, label: l.paywallBestValue),
                            ],
                          ]),
                          if (p.hasFreeTrial && p.trialDays != null)
                            Text(l.paywallTrial('${p.trialDays}', p.priceLabel), style: context.text.bodySmall)
                          else
                            Text(p.priceLabel, style: context.text.bodyMedium),
                          if (p.monthlyEquivalentLabel != null)
                            Text(l.paywallPerMonth(p.monthlyEquivalentLabel!), style: context.text.bodySmall),
                        ]),
                      ),
                      Icon(selectedPlan?.period == p.period ? Icons.check_circle : Icons.circle_outlined,
                          color: selectedPlan?.period == p.period ? t.accent : t.hairline),
                    ]),
                  ),
                ),
              ),
            const SizedBox(height: Gap.md),
            FilledButton(
              onPressed: (_busy || selectedPlan == null) ? null : () => _buy(selectedPlan),
              child: Text(l.paywallContinue),
            ),
          ],
          const SizedBox(height: Gap.sm),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(onPressed: _busy ? null : _restore, child: Text(l.paywallRestore)),
            TextButton(onPressed: () => openUrl(context, _manageUrl), child: Text(l.paywallManage)),
          ]),
          const SizedBox(height: Gap.md),
          Text(l.paywallTerms, style: context.text.bodySmall),
          Row(children: [
            TextButton(onPressed: () => openUrl(context, AppConfig.termsUrl), child: Text(l.privacyTerms)),
            TextButton(onPressed: () => openUrl(context, AppConfig.privacyPolicyUrl), child: Text(l.privacyPolicy)),
          ]),
        ]),
      ),
    );
  }
}
