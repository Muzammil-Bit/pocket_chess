import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.gradientColors,
    required this.cardBackground,
    required this.cardBorder,
    required this.cardShadow,
    required this.glowOrbPrimary,
    required this.glowOrbSecondary,
    required this.textHeading,
    required this.textMuted,
    required this.sectionHeader,
    required this.accentPrimary,
    required this.accentBorder,
    required this.panelBackground,
    required this.panelBorder,
    required this.statusBadgeBg,
    required this.statusBadgeActiveBg,
    required this.statusBadgeBorder,
    required this.statusBadgeActiveBorder,
    required this.boardFrameGradientStart,
    required this.boardFrameGradientEnd,
    required this.boardFrameBorder,
    required this.boardGlowColors,
    required this.promotionItemBg,
    required this.promotionItemBorder,
    required this.chessIconGradientStart,
    required this.chessIconGradientEnd,
    required this.chessIconBorder,
    required this.activeIndicator,
    required this.inactiveIndicator,
    required this.activeText,
    required this.inactiveText,
    required this.avatarInitialsColor,
    required this.boardBackdropStroke,
    required this.boardInnerBg,
    required this.axisLabelColor,
  });

  final List<Color> gradientColors;
  final Color cardBackground;
  final Color cardBorder;
  final Color cardShadow;
  final Color glowOrbPrimary;
  final Color glowOrbSecondary;
  final Color textHeading;
  final Color textMuted;
  final Color sectionHeader;
  final Color accentPrimary;
  final Color accentBorder;
  final Color panelBackground;
  final Color panelBorder;
  final Color statusBadgeBg;
  final Color statusBadgeActiveBg;
  final Color statusBadgeBorder;
  final Color statusBadgeActiveBorder;
  final Color boardFrameGradientStart;
  final Color boardFrameGradientEnd;
  final Color boardFrameBorder;
  final List<Color> boardGlowColors;
  final Color promotionItemBg;
  final Color promotionItemBorder;
  final Color chessIconGradientStart;
  final Color chessIconGradientEnd;
  final Color chessIconBorder;
  final Color activeIndicator;
  final Color inactiveIndicator;
  final Color activeText;
  final Color inactiveText;
  final Color avatarInitialsColor;
  final Color boardBackdropStroke;
  final Color boardInnerBg;
  final Color axisLabelColor;

  static const dark = AppColors(
    gradientColors: [Color(0xFF090B18), Color(0xFF121735), Color(0xFF1B2350)],
    cardBackground: Color(0xFF0D1128),
    cardBorder: Color(0xFF262E57),
    cardShadow: Color(0x44070A16),
    glowOrbPrimary: Color(0x60505FFF),
    glowOrbSecondary: Color(0x303B4275),
    textHeading: Color(0xFFF6F7FF),
    textMuted: Color(0xFF8B95C9),
    sectionHeader: Color(0xFFAEB7E5),
    accentPrimary: Color(0xFF4D5BFF),
    accentBorder: Color(0xFF6C7BFF),
    panelBackground: Color(0xFF171B35),
    panelBorder: Color(0xFF2D3361),
    statusBadgeBg: Color(0xF520274D),
    statusBadgeActiveBg: Color(0xFF2A3060),
    statusBadgeBorder: Color(0xFF3A4278),
    statusBadgeActiveBorder: Color(0xFF6876FF),
    boardFrameGradientStart: Color(0xE61A2146),
    boardFrameGradientEnd: Color(0xD41B244D),
    boardFrameBorder: Color(0x66E6ECFF),
    boardGlowColors: [
      Color(0x666F7DFF),
      Color(0x386276FF),
      Color(0x0B3D4D8D),
      Color(0x00333D7A),
    ],
    promotionItemBg: Color(0xFF20274D),
    promotionItemBorder: Color(0xFF39427A),
    chessIconGradientStart: Color(0xFF2A3060),
    chessIconGradientEnd: Color(0xFF1E2450),
    chessIconBorder: Color(0xFF363F6E),
    activeIndicator: Color(0xFF6C7BFF),
    inactiveIndicator: Color(0xFF3A426E),
    activeText: Color(0xFFF5F7FF),
    inactiveText: Color(0xFFB8C2EF),
    avatarInitialsColor: Color(0xFF0F1430),
    boardBackdropStroke: Color(0x12FFFFFF),
    boardInnerBg: Color(0x2610152D),
    axisLabelColor: Color(0x9EE7ECFF),
  );

  static const light = AppColors(
    gradientColors: [Color(0xFFF2F4FB), Color(0xFFE8ECF7), Color(0xFFDFE4F4)],
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFD0D5E8),
    cardShadow: Color(0x1A3040A0),
    glowOrbPrimary: Color(0x28505FFF),
    glowOrbSecondary: Color(0x18A0AAD0),
    textHeading: Color(0xFF1A1D2E),
    textMuted: Color(0xFF6B7194),
    sectionHeader: Color(0xFF5A6080),
    accentPrimary: Color(0xFF4D5BFF),
    accentBorder: Color(0xFF6C7BFF),
    panelBackground: Color(0xFFFFFFFF),
    panelBorder: Color(0xFFD0D5E8),
    statusBadgeBg: Color(0xFFF0F2FA),
    statusBadgeActiveBg: Color(0xFFE0E4FF),
    statusBadgeBorder: Color(0xFFD0D5E8),
    statusBadgeActiveBorder: Color(0xFF8B96FF),
    boardFrameGradientStart: Color(0xE6E8ECF7),
    boardFrameGradientEnd: Color(0xD4DFE4F4),
    boardFrameBorder: Color(0x66A0AAD0),
    boardGlowColors: [
      Color(0x336F7DFF),
      Color(0x1A6276FF),
      Color(0x08A0AAD0),
      Color(0x00C0C6D8),
    ],
    promotionItemBg: Color(0xFFF0F2FA),
    promotionItemBorder: Color(0xFFD0D5E8),
    chessIconGradientStart: Color(0xFFE0E4FF),
    chessIconGradientEnd: Color(0xFFD0D5F0),
    chessIconBorder: Color(0xFFB8C0E0),
    activeIndicator: Color(0xFF4D5BFF),
    inactiveIndicator: Color(0xFFD0D5E8),
    activeText: Color(0xFF1A1D2E),
    inactiveText: Color(0xFF8A90B0),
    avatarInitialsColor: Color(0xFF1A1D2E),
    boardBackdropStroke: Color(0x0A000000),
    boardInnerBg: Color(0x12E8ECF7),
    axisLabelColor: Color(0x9E5A6080),
  );

  @override
  AppColors copyWith({
    List<Color>? gradientColors,
    Color? cardBackground,
    Color? cardBorder,
    Color? cardShadow,
    Color? glowOrbPrimary,
    Color? glowOrbSecondary,
    Color? textHeading,
    Color? textMuted,
    Color? sectionHeader,
    Color? accentPrimary,
    Color? accentBorder,
    Color? panelBackground,
    Color? panelBorder,
    Color? statusBadgeBg,
    Color? statusBadgeActiveBg,
    Color? statusBadgeBorder,
    Color? statusBadgeActiveBorder,
    Color? boardFrameGradientStart,
    Color? boardFrameGradientEnd,
    Color? boardFrameBorder,
    List<Color>? boardGlowColors,
    Color? promotionItemBg,
    Color? promotionItemBorder,
    Color? chessIconGradientStart,
    Color? chessIconGradientEnd,
    Color? chessIconBorder,
    Color? activeIndicator,
    Color? inactiveIndicator,
    Color? activeText,
    Color? inactiveText,
    Color? avatarInitialsColor,
    Color? boardBackdropStroke,
    Color? boardInnerBg,
    Color? axisLabelColor,
  }) {
    return AppColors(
      gradientColors: gradientColors ?? this.gradientColors,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      glowOrbPrimary: glowOrbPrimary ?? this.glowOrbPrimary,
      glowOrbSecondary: glowOrbSecondary ?? this.glowOrbSecondary,
      textHeading: textHeading ?? this.textHeading,
      textMuted: textMuted ?? this.textMuted,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentBorder: accentBorder ?? this.accentBorder,
      panelBackground: panelBackground ?? this.panelBackground,
      panelBorder: panelBorder ?? this.panelBorder,
      statusBadgeBg: statusBadgeBg ?? this.statusBadgeBg,
      statusBadgeActiveBg: statusBadgeActiveBg ?? this.statusBadgeActiveBg,
      statusBadgeBorder: statusBadgeBorder ?? this.statusBadgeBorder,
      statusBadgeActiveBorder:
          statusBadgeActiveBorder ?? this.statusBadgeActiveBorder,
      boardFrameGradientStart:
          boardFrameGradientStart ?? this.boardFrameGradientStart,
      boardFrameGradientEnd:
          boardFrameGradientEnd ?? this.boardFrameGradientEnd,
      boardFrameBorder: boardFrameBorder ?? this.boardFrameBorder,
      boardGlowColors: boardGlowColors ?? this.boardGlowColors,
      promotionItemBg: promotionItemBg ?? this.promotionItemBg,
      promotionItemBorder: promotionItemBorder ?? this.promotionItemBorder,
      chessIconGradientStart:
          chessIconGradientStart ?? this.chessIconGradientStart,
      chessIconGradientEnd: chessIconGradientEnd ?? this.chessIconGradientEnd,
      chessIconBorder: chessIconBorder ?? this.chessIconBorder,
      activeIndicator: activeIndicator ?? this.activeIndicator,
      inactiveIndicator: inactiveIndicator ?? this.inactiveIndicator,
      activeText: activeText ?? this.activeText,
      inactiveText: inactiveText ?? this.inactiveText,
      avatarInitialsColor: avatarInitialsColor ?? this.avatarInitialsColor,
      boardBackdropStroke: boardBackdropStroke ?? this.boardBackdropStroke,
      boardInnerBg: boardInnerBg ?? this.boardInnerBg,
      axisLabelColor: axisLabelColor ?? this.axisLabelColor,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      gradientColors: [
        for (var i = 0; i < gradientColors.length; i++)
          Color.lerp(gradientColors[i], other.gradientColors[i], t)!,
      ],
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      glowOrbPrimary: Color.lerp(glowOrbPrimary, other.glowOrbPrimary, t)!,
      glowOrbSecondary: Color.lerp(
        glowOrbSecondary,
        other.glowOrbSecondary,
        t,
      )!,
      textHeading: Color.lerp(textHeading, other.textHeading, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      sectionHeader: Color.lerp(sectionHeader, other.sectionHeader, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentBorder: Color.lerp(accentBorder, other.accentBorder, t)!,
      panelBackground: Color.lerp(panelBackground, other.panelBackground, t)!,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t)!,
      statusBadgeBg: Color.lerp(statusBadgeBg, other.statusBadgeBg, t)!,
      statusBadgeActiveBg: Color.lerp(
        statusBadgeActiveBg,
        other.statusBadgeActiveBg,
        t,
      )!,
      statusBadgeBorder: Color.lerp(
        statusBadgeBorder,
        other.statusBadgeBorder,
        t,
      )!,
      statusBadgeActiveBorder: Color.lerp(
        statusBadgeActiveBorder,
        other.statusBadgeActiveBorder,
        t,
      )!,
      boardFrameGradientStart: Color.lerp(
        boardFrameGradientStart,
        other.boardFrameGradientStart,
        t,
      )!,
      boardFrameGradientEnd: Color.lerp(
        boardFrameGradientEnd,
        other.boardFrameGradientEnd,
        t,
      )!,
      boardFrameBorder: Color.lerp(
        boardFrameBorder,
        other.boardFrameBorder,
        t,
      )!,
      boardGlowColors: [
        for (var i = 0; i < boardGlowColors.length; i++)
          Color.lerp(boardGlowColors[i], other.boardGlowColors[i], t)!,
      ],
      promotionItemBg: Color.lerp(promotionItemBg, other.promotionItemBg, t)!,
      promotionItemBorder: Color.lerp(
        promotionItemBorder,
        other.promotionItemBorder,
        t,
      )!,
      chessIconGradientStart: Color.lerp(
        chessIconGradientStart,
        other.chessIconGradientStart,
        t,
      )!,
      chessIconGradientEnd: Color.lerp(
        chessIconGradientEnd,
        other.chessIconGradientEnd,
        t,
      )!,
      chessIconBorder: Color.lerp(chessIconBorder, other.chessIconBorder, t)!,
      activeIndicator: Color.lerp(activeIndicator, other.activeIndicator, t)!,
      inactiveIndicator: Color.lerp(
        inactiveIndicator,
        other.inactiveIndicator,
        t,
      )!,
      activeText: Color.lerp(activeText, other.activeText, t)!,
      inactiveText: Color.lerp(inactiveText, other.inactiveText, t)!,
      avatarInitialsColor: Color.lerp(
        avatarInitialsColor,
        other.avatarInitialsColor,
        t,
      )!,
      boardBackdropStroke: Color.lerp(
        boardBackdropStroke,
        other.boardBackdropStroke,
        t,
      )!,
      boardInnerBg: Color.lerp(boardInnerBg, other.boardInnerBg, t)!,
      axisLabelColor: Color.lerp(axisLabelColor, other.axisLabelColor, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
