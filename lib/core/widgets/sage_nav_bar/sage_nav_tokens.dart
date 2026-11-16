import 'package:flutter/material.dart';

abstract final class SageNavTokens {
  static const pageBackground = Color(0xFF131313);
  static const barColor = Color(0xFF2A313C);
  static const barShadow = Color(0x80000000);
  static const centerColor = Color(0xFF2F6BBF);
  static const centerHalo = Color(0xFF232A33);
  static const centerRipple = Color(0x66FFFFFF);
  static const indicatorColor = Color(0xFF7FB4FF);
  static const iconColor = Color(0xFFFFFFFF);
  static const unreadColor = Color(0xFFF59A2B);
  static const avatarRing = Color(0xFF4F86D9);
  static const bubbleColor = Color(0xFF3A4352);
  static const scrimColor = Color(0x99000000);

  static const double barBodyHeight = 55;
  static const double domeDepth = 11;
  static const double centerDiameter = 78;
  static const double haloWidth = 9;
  static const double centerLift = centerDiameter / 2 + haloWidth;
  static const double tabIconSize = 30;
  static const double tabIconStroke = 2.2;
  static const double tabLabelSize = 11;
  static const double indicatorWidth = 22;
  static const double indicatorHeight = 4;
  static const double unreadDotSize = 11;
  static const double avatarSize = 34;
  static const double avatarRingWidth = 2;
  static const double bubbleSize = 54;
  static const double minTapTarget = 48;
  static const double maxBarWidth = 600;
  static const double horizontalPadding = 8;

  static const double centerPressScale = 0.9;
  static const double centerMenuOpenScale = 0.92;
  static const double centerPulseMaxScale = 1.55;
  static const double badgePingMaxScale = 2.6;
  static const double boingLift = 10;
  static const double boingScale = 1.22;

  static const List<Offset> bubbleOffsets = [
    Offset(-86, -62),
    Offset(0, -108),
    Offset(86, -62),
  ];

  static const entranceDuration = Duration(milliseconds: 1000);
  static const boingDuration = Duration(milliseconds: 550);
  static const indicatorDuration = Duration(milliseconds: 550);
  static const badgePingDuration = Duration(milliseconds: 1800);
  static const centerPulseDuration = Duration(milliseconds: 2400);
  static const rippleDuration = Duration(milliseconds: 600);
  static const fanDuration = Duration(milliseconds: 550);
  static const fanStagger = Duration(milliseconds: 70);
  static const closeDuration = Duration(milliseconds: 350);
  static const pressDuration = Duration(milliseconds: 120);

  static const Curve entranceBarCurve = Curves.easeOutBack;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve springCurve = Curves.easeOutBack;
}
