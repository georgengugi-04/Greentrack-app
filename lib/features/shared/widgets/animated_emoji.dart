import 'package:flutter/material.dart';

/// Plain, static emoji glyph. This used to animate (bounce/wiggle/pop) but
/// that turned out to be the wrong idea — it's reverted to a flat Text
/// on purpose. Kept as a drop-in wrapper so every call site that already
/// uses AnimatedEmoji(...) doesn't need to be touched again; for a real
/// character animation, see ChefCookingIllustration instead.
class AnimatedEmoji extends StatelessWidget {
  final String emoji;
  final double size;

  const AnimatedEmoji(this.emoji, {this.size = 24, super.key});

  @override
  Widget build(BuildContext context) => Text(emoji, style: TextStyle(fontSize: size));
}
