import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Intensity of the glass. Switch it to compare both looks; nothing else has to change.
///
/// * [GlassStyle.subtle]: discreet glass, close to the Android app.
/// * [GlassStyle.vivid]: clearer, more saturated glass with a lens edge, for a modern look.
enum GlassStyle { subtle, vivid }

/// Style used by the whole app.
const GlassStyle kGlassStyle = GlassStyle.vivid;

/// Materials of the app, split in two layers like Apple's liquid glass.
///
/// * Content layer: screens sit on a flat [background] and cards, inputs and chips use an opaque
///   [surface] with a hairline [border]. No gradients and no shadows, so data reads cleanly.
/// * Glass layer: what floats over the content (bottom bar, top bar buttons, collapsing header,
///   form action bar) uses the translucent [glass] fill with blur and one light [glassBorder]
///   rim, so the content is seen scrolling behind it. Inputs and the search field stay solid. Sheets, dialogs and menus use the almost
///   opaque [overlay] so their text keeps full contrast.
///
/// When the system asks for more contrast every material turns opaque and the blur is removed.
@immutable
class GlassTokens {
  /// Creates a set of tokens.
  const GlassTokens({
    required this.background,
    required this.surface,
    required this.track,
    required this.border,
    required this.glass,
    required this.glassBorder,
    required this.overlay,
    required this.shadow,
    required this.scrim,
    required this.blurSigma,
    required this.control,
    this.saturation = 1,
    this.headerOpacity = 0.86,
  });

  /// Flat color painted behind every screen.
  final Color background;

  /// Opaque fill of cards, inputs, chips and outlined buttons.
  final Color surface;

  /// Recessed fill of segmented tabs, under the selected pill.
  final Color track;

  /// Hairline that separates content surfaces from the background.
  final Color border;

  /// Translucent fill of the floating navigation and controls.
  final Color glass;

  /// Light rim of the glass, which reads as its edge over the content behind.
  final Color glassBorder;

  /// Fill of sheets, dialogs and menus.
  final Color overlay;

  /// Shadow of floating elements only.
  final Color shadow;

  /// Color laid over the screen behind sheets and dialogs.
  final Color scrim;

  /// Blur applied to what is behind the glass.
  final double blurSigma;

  /// Color saturation of what is seen through the glass; above 1 the content behind glows.
  final double saturation;

  /// Fill of small glass controls (round top bar buttons). They usually sit over the flat
  /// background, so they need more body than the bars to be seen.
  final Color control;

  /// Opacity of the background behind the collapsing header.
  final double headerOpacity;

  /// Vivid tokens of the light theme.
  static const GlassTokens lightVivid = GlassTokens(
    background: Color(0xFFF2F3FA),
    surface: Color(0xFFFFFFFF),
    track: Color(0xFFE6E8EF),
    border: Color(0xFFE5E7EE),
    glass: Color(0x7AFFFFFF),
    glassBorder: Color(0xE6FFFFFF),
    control: Color(0xD9FFFFFF),
    overlay: Color(0xEBFFFFFF),
    shadow: Color(0x241C3A5E),
    scrim: Color(0x42101828),
    blurSigma: 30,
    saturation: 1.5,
    headerOpacity: 0.55,
  );

  /// Vivid tokens of the dark theme.
  static const GlassTokens darkVivid = GlassTokens(
    background: Color(0xFF111418),
    surface: Color(0xFF1B2028),
    track: Color(0xFF0B0E12),
    border: Color(0x1FFFFFFF),
    glass: Color(0x661B2028),
    glassBorder: Color(0x2EFFFFFF),
    control: Color(0xB32A313C),
    overlay: Color(0xE61B2028),
    shadow: Color(0x73000000),
    scrim: Color(0x8C000000),
    blurSigma: 30,
    saturation: 1.4,
    headerOpacity: 0.55,
  );

  /// Subtle tokens of the light theme.
  static const GlassTokens light = GlassTokens(
    background: Color(0xFFF2F3FA),
    surface: Color(0xFFFFFFFF),
    track: Color(0xFFE6E8EF),
    border: Color(0xFFE5E7EE),
    glass: Color(0xB8FFFFFF),
    glassBorder: Color(0x99FFFFFF),
    control: Color(0xE6FFFFFF),
    overlay: Color(0xF5FFFFFF),
    shadow: Color(0x141C3A5E),
    scrim: Color(0x52101828),
    blurSigma: 24,
  );

  /// Subtle tokens of the dark theme.
  static const GlassTokens dark = GlassTokens(
    background: Color(0xFF111418),
    surface: Color(0xFF1B2028),
    track: Color(0xFF0B0E12),
    border: Color(0x1FFFFFFF),
    glass: Color(0xA61B2028),
    glassBorder: Color(0x29FFFFFF),
    control: Color(0xCC2A313C),
    overlay: Color(0xF21B2028),
    shadow: Color(0x59000000),
    scrim: Color(0x99000000),
    blurSigma: 24,
  );

  /// Tokens for the current theme, opaque when the system requests high contrast.
  static GlassTokens of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final GlassTokens tokens = kGlassStyle == GlassStyle.vivid
        ? (isDark ? darkVivid : lightVivid)
        : (isDark ? dark : light);
    if (!MediaQuery.highContrastOf(context)) return tokens;
    final ColorScheme scheme = theme.colorScheme;
    return GlassTokens(
      background: scheme.surface,
      surface: scheme.surfaceContainerLow,
      track: scheme.surfaceContainerHigh,
      border: scheme.outline,
      glass: scheme.surfaceContainerHigh,
      glassBorder: scheme.outline,
      control: scheme.surfaceContainerHigh,
      overlay: scheme.surfaceContainerHigh,
      shadow: Colors.transparent,
      scrim: tokens.scrim,
      blurSigma: 0,
    );
  }

  /// Filter of what is behind the glass: blur plus the saturation boost of the style.
  ui.ImageFilter get backdrop => backdropWith(blurSigma);

  /// Same as [backdrop] with a custom [sigma], for small controls.
  ui.ImageFilter backdropWith(double sigma) {
    final ui.ImageFilter blur = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
    if (saturation == 1) return blur;
    const double r = 0.2126;
    const double g = 0.7152;
    const double b = 0.0722;
    final double s = saturation;
    final ui.ColorFilter saturate = ui.ColorFilter.matrix(<double>[
      (1 - s) * r + s, (1 - s) * g, (1 - s) * b, 0, 0, //
      (1 - s) * r, (1 - s) * g + s, (1 - s) * b, 0, 0, //
      (1 - s) * r, (1 - s) * g, (1 - s) * b + s, 0, 0, //
      0, 0, 0, 1, 0,
    ]);
    return ui.ImageFilter.compose(outer: saturate, inner: blur);
  }

  /// Shadow of the floating glass (bottom bar, search field, menus).
  List<BoxShadow> get elevation => <BoxShadow>[
        BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, 6)),
      ];

  /// Small shadow of controls and of a selected pill inside a track.
  List<BoxShadow> get raised => <BoxShadow>[
        BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2)),
      ];

  /// Fill of the skeleton placeholders shown while data loads.
  Color skeletonOn(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0x1AFFFFFF) : const Color(0xFFE6E8EF);
}
