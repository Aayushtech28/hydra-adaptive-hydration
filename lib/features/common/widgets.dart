import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Standard surface card.
class HCard extends StatelessWidget {
  const HCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.lg),
    this.onTap,
    this.color,
    this.semanticsLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    final card = Material(
      color: color ?? t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: t.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
    return semanticsLabel == null ? card : Semantics(label: semanticsLabel, child: card);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, Gap.xl, 0, Gap.sm),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: context.text.titleMedium),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

enum StatusKind { good, adjust, attention, neutral }

/// Status pill: symbol + text (never colour alone).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.kind, required this.label});
  final StatusKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    final (Color c, String sym) = switch (kind) {
      StatusKind.good => (t.good, '✓'),
      StatusKind.adjust => (t.adjust, '→'),
      StatusKind.attention => (t.attention, '!'),
      StatusKind.neutral => (t.inkMuted, '•'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(sym, style: context.text.labelLarge?.copyWith(color: c)),
          ),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: context.text.labelLarge?.copyWith(color: c))),
        ],
      ),
    );
  }
}

/// Informative empty state: what is happening, why, and what to do next.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? Gap.lg : Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: t.accentSoft, shape: BoxShape.circle),
              child: Icon(icon, color: t.accent, semanticLabel: ''),
            ),
            const SizedBox(height: Gap.md),
            Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: Gap.xs),
            Text(message,
                style: context.text.bodyMedium?.copyWith(color: t.inkMuted),
                textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: Gap.lg), action!],
          ],
        ),
      ),
    );
  }
}

/// Recoverable-error state with explicit actions. Never blocks core tracking.
class ErrorNotice extends StatelessWidget {
  const ErrorNotice({
    super.key,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return HCard(
      color: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('!', style: context.text.titleMedium?.copyWith(color: t.attention)),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: context.text.titleSmall)),
          ]),
          const SizedBox(height: 4),
          Text(message, style: context.text.bodyMedium?.copyWith(color: t.inkMuted)),
          if (primaryLabel != null || secondaryLabel != null) ...[
            const SizedBox(height: Gap.md),
            Wrap(spacing: 8, children: [
              if (primaryLabel != null)
                FilledButton(onPressed: onPrimary, child: Text(primaryLabel!)),
              if (secondaryLabel != null)
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ]),
          ],
        ],
      ),
    );
  }
}

/// A skeleton line used while local data first loads (rare; local reads are
/// fast so this is shown at most for a frame or two).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.height = 16, this.width, this.radius = 8});
  final double height;
  final double? width;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: context.hx.surfaceRaised,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Settings-style row.
class HTile extends StatelessWidget {
  const HTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.badge,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTap + 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
          child: Row(
            children: [
              if (leading != null) ...[
                Icon(leading, color: t.accent, size: 22),
                const SizedBox(width: Gap.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(child: Text(title, style: context.text.bodyLarge)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: t.accentSoft,
                            borderRadius: BorderRadius.circular(Radii.pill),
                          ),
                          child: Text(badge!, style: context.text.labelSmall?.copyWith(color: t.accent)),
                        ),
                      ],
                    ]),
                    if (subtitle != null)
                      Text(subtitle!, style: context.text.bodySmall),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (trailing == null && onTap != null)
                Icon(Icons.chevron_right, color: t.inkMuted, semanticLabel: ''),
            ],
          ),
        ),
      ),
    );
  }
}

/// Groups tiles in a rounded card with dividers.
class TileGroup extends StatelessWidget {
  const TileGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: t.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: Gap.lg, color: t.hairline),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Page scaffold body padding that respects screen gutters.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.bottom = Gap.xxl});
  final List<Widget> children;
  final double bottom;

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.fromLTRB(Gap.screen, Gap.sm, Gap.screen, bottom),
        children: children,
      );
}
