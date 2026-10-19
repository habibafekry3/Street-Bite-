import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF900C3F);
  static const Color primaryDark = Color(0xFF581845);

  // ── Card gradient ─────────────────────────────────────────────────────────
  static const List<Color> cardGradient = [primaryDark, primary];

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color deposit = Color(0xFF10B981);
  static const Color withdraw = Color(0xFFE11D48);
  static const Color error = Color(0xFFE11D48);
  static const Color success = Color(0xFF10B981);
  static const Color successAccent = Colors.greenAccent;

  // ── Text / Surface ────────────────────────────────────────────────────────
  static const Color textOnCard = Colors.white;
  static const Color textOnCardMuted = Colors.white70;
  static const Color textMuted = Colors.grey;
  static const Color blackColor = Colors.black;
}
