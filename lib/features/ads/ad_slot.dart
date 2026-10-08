import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../services/ads/ad_policy.dart';

/// Shows an ad for [placement] **only if** the central policy allows it and
/// one actually loads; otherwise it occupies zero space. Only secondary
/// screens use it — there is no placement for the dashboard or logging flow.
class AdSlot extends ConsumerStatefulWidget {
  const AdSlot({super.key, required this.placement});
  final AdPlacement placement;

  @override
  ConsumerState<AdSlot> createState() => _AdSlotState();
}

class _AdSlotState extends ConsumerState<AdSlot> {
  Ad? _ad;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    _load();
  }

  Future<void> _load() async {
    try {
      await _loadInner();
    } catch (_) {
      // Ads are optional: any failure simply leaves the slot empty.
    }
  }

  Future<void> _loadInner() async {
    if (widget.placement.format != AdFormat.banner && widget.placement.format != AdFormat.native) {
      return;
    }
    final svc = ref.read(servicesProvider);
    if (ref.read(isProProvider)) return;
    final decision = await svc.adCoordinator.decide(widget.placement);
    if (!decision.allowed || !mounted) return;
    final width = MediaQuery.sizeOf(context).width.truncate() - 40;
    final ad = widget.placement.format == AdFormat.banner
        ? await svc.ads.loadBanner(width)
        : await svc.ads.loadNative();
    if (!mounted || ad == null) {
      ad?.dispose();
      return;
    }
    // A user who upgraded while the ad loaded never sees it.
    if (ref.read(isProProvider)) {
      ad.dispose();
      return;
    }
    setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isProProvider, (_, pro) {
      if (pro && _ad != null) {
        _ad!.dispose();
        setState(() => _ad = null);
      }
    });
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final isNative = ad is NativeAd;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.md),
      child: Semantics(
        label: l.adLabel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.adLabel, style: context.text.labelSmall),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.md),
              child: SizedBox(
                height: isNative ? 120 : (ad as BannerAd).size.height.toDouble(),
                width: isNative ? double.infinity : (ad as BannerAd).size.width.toDouble(),
                child: AdWidget(ad: ad as AdWithView),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
