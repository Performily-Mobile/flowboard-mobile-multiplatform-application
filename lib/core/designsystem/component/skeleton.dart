import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Loading placeholders that copy the shape of the content that is about to appear.
///
/// The blocks are flat and pulse softly in opacity (no shimmer gradient). When the system asks to
/// reduce motion the pulse stops. Screen readers hear a single "Cargando" instead of the blocks.
class SkeletonPulse extends StatefulWidget {
  /// Creates the pulse around the placeholder [child].
  const SkeletonPulse({super.key, required this.child, this.label = 'Cargando'});

  final Widget child;
  final String label;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _opacity = Tween<double>(begin: 1, end: 0.5).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: FadeTransition(opacity: _opacity, child: widget.child),
      ),
    );
  }
}

/// Flat rounded block of a skeleton.
class SkeletonBox extends StatelessWidget {
  /// Creates a block of [height]; without [width] it fills the available width.
  const SkeletonBox({super.key, this.width, required this.height, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final Color color = GlassTokens.of(context).skeletonOn(Theme.of(context).brightness);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

/// Round block of a skeleton, used for avatars.
class SkeletonCircle extends StatelessWidget {
  /// Creates the circle with its [size].
  const SkeletonCircle({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) => SkeletonBox(width: size, height: size, radius: size / 2);
}

/// Placeholder of a list row: avatar, two lines of text and a status chip.
class SkeletonListTile extends StatelessWidget {
  /// Creates the row; [showAvatar] and [showTrailing] match the real row.
  const SkeletonListTile({super.key, this.showAvatar = true, this.showTrailing = true});

  final bool showAvatar;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          if (showAvatar) const SkeletonCircle(),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: <Widget>[
                FractionallySizedBox(widthFactor: 0.7, child: SkeletonBox(height: 14)),
                FractionallySizedBox(widthFactor: 0.45, child: SkeletonBox(height: 12)),
              ],
            ),
          ),
          if (showTrailing) const SkeletonBox(width: 64, height: 24, radius: 999),
        ],
      ),
    );
  }
}

/// Placeholder of a whole list.
///
/// By default it is a non-scrollable [ListView] that fills the space; with [inline] it is a
/// plain column to place inside another scroll view.
class SkeletonList extends StatelessWidget {
  /// Creates the list with [itemCount] rows and its outer [padding].
  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
    this.inline = false,
    this.showAvatar = true,
    this.showTrailing = true,
  });

  final int itemCount;
  final EdgeInsetsGeometry padding;
  final bool inline;
  final bool showAvatar;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[
      for (int i = 0; i < itemCount; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
          child: SkeletonListTile(showAvatar: showAvatar, showTrailing: showTrailing),
        ),
    ];
    if (inline) {
      return SkeletonPulse(
        child: Padding(
          padding: padding,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ),
      );
    }
    return SkeletonPulse(
      child: ListView(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        children: rows,
      ),
    );
  }
}

/// Placeholder of a record screen (employee detail and my profile): header with avatar, a tab
/// bar and blocks of label and value rows.
class SkeletonDetail extends StatelessWidget {
  /// Creates the placeholder; [showTabs] matches screens with a tab bar.
  const SkeletonDetail({super.key, this.showTabs = true});

  final bool showTabs;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.m,
          AppSpacing.screenHorizontal,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sectionGap,
          children: <Widget>[
            const Row(
              spacing: AppSpacing.l,
              children: <Widget>[
                SkeletonCircle(size: 72),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: <Widget>[
                      FractionallySizedBox(widthFactor: 0.75, child: SkeletonBox(height: 20)),
                      FractionallySizedBox(widthFactor: 0.5, child: SkeletonBox(height: 14)),
                      SkeletonBox(width: 72, height: 24, radius: 999),
                    ],
                  ),
                ),
              ],
            ),
            if (showTabs) const SkeletonBox(height: 48, radius: 999),
            for (int block = 0; block < 2; block++)
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.l,
                  children: <Widget>[
                    for (int row = 0; row < 4; row++)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: <Widget>[
                          FractionallySizedBox(widthFactor: 0.3, child: SkeletonBox(height: 11)),
                          FractionallySizedBox(widthFactor: 0.65, child: SkeletonBox(height: 15)),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder of a form: labelled fields stacked with the form spacing.
class SkeletonForm extends StatelessWidget {
  /// Creates the placeholder with [fieldCount] fields.
  const SkeletonForm({super.key, this.fieldCount = 6});

  final int fieldCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.l,
          children: <Widget>[
            for (int i = 0; i < fieldCount; i++)
              const SkeletonBox(height: 56, radius: AppShapes.extraSmallRadius),
          ],
        ),
      ),
    );
  }
}
