import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';

/// Layout whose header (search box, filters, tabs) slides away while the list scrolls down and
/// comes back as soon as the user scrolls up, like the search bar of Gmail.
///
/// The header is a blurred glass strip, so the list can be seen moving behind it. The content
/// must be scrollable (usually a [ListView]) and must apply the padding given by
/// [contentBuilder] so its first item starts below the header.
class CollapsingHeaderLayout extends StatefulWidget {
  /// Creates the layout.
  ///
  /// [header] is the collapsing block, [contentBuilder] builds the scrollable content with the
  /// padding that leaves room for the header, whenever [showHeaderKey] changes the header is
  /// shown again (pass something that changes when the content may stop being scrollable), and
  /// [onHeaderVisibilityChanged] tells when at least half of the header is visible, which is
  /// useful to expand or shrink a floating button.
  const CollapsingHeaderLayout({
    super.key,
    required this.header,
    required this.contentBuilder,
    this.showHeaderKey,
    this.onHeaderVisibilityChanged,
  });

  final Widget header;
  final Widget Function(BuildContext context, EdgeInsets contentPadding) contentBuilder;
  final Object? showHeaderKey;
  final ValueChanged<bool>? onHeaderVisibilityChanged;

  @override
  State<CollapsingHeaderLayout> createState() => _CollapsingHeaderLayoutState();
}

class _CollapsingHeaderLayoutState extends State<CollapsingHeaderLayout> {
  final GlobalKey _headerKey = GlobalKey();
  double _offset = 0;
  double _height = 0;
  bool _headerVisible = true;

  @override
  void didUpdateWidget(CollapsingHeaderLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showHeaderKey != widget.showHeaderKey) {
      _offset = 0;
      _reportVisibility();
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical) {
      final double delta = notification.scrollDelta ?? 0;
      final double next = (_offset - delta).clamp(-_height, 0.0);
      if (next != _offset) {
        setState(() => _offset = next);
        _reportVisibility();
      }
    }
    return false;
  }

  void _reportVisibility() {
    final bool visible = _height == 0 || _offset > -_height / 2;
    if (visible != _headerVisible) {
      _headerVisible = visible;
      widget.onHeaderVisibilityChanged?.call(visible);
    }
  }

  void _measureHeader() {
    final double? measured = _headerKey.currentContext?.size?.height;
    if (measured != null && measured != _height) {
      setState(() => _height = measured);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measureHeader();
    });

    return ClipRect(
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          children: <Widget>[
            widget.contentBuilder(context, EdgeInsets.only(top: _height)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(0, _offset),
                child: ClipRect(
                  key: _headerKey,
                  child: BackdropFilter(
                    filter: tokens.backdrop,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: tokens.background.withValues(alpha: tokens.headerOpacity)),
                      child: widget.header,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
