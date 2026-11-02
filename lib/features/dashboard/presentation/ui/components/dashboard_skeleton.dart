import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Placeholder of the dashboard while it loads: four indicator cards and two section cards.
class DashboardSkeleton extends StatelessWidget {
  /// Creates the placeholder with the same outer [padding] as the real list.
  const DashboardSkeleton({super.key, required this.padding});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sectionGap,
          children: <Widget>[
            const Column(
              spacing: AppSpacing.m,
              children: <Widget>[
                Row(spacing: AppSpacing.m, children: <Widget>[Expanded(child: _MetricPlaceholder()), Expanded(child: _MetricPlaceholder())]),
                Row(spacing: AppSpacing.m, children: <Widget>[Expanded(child: _MetricPlaceholder()), Expanded(child: _MetricPlaceholder())]),
              ],
            ),
            _SectionPlaceholder(rows: 3),
            _SectionPlaceholder(rows: 3),
          ],
        ),
      ),
    );
  }
}

class _MetricPlaceholder extends StatelessWidget {
  const _MetricPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      padding: EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: <Widget>[
          SkeletonCircle(size: 36),
          SkeletonBox(width: 48, height: 28),
          SkeletonBox(height: 14),
        ],
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.l,
        children: <Widget>[
          const SkeletonBox(width: 160, height: 18),
          for (int i = 0; i < rows; i++) const SkeletonBox(height: 14),
        ],
      ),
    );
  }
}
