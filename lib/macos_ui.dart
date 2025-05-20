import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:macos_ui/macos_ui.dart';

final class MutedMacosIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const MutedMacosIconButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MacosIconButton(
      hoverColor: Colors.transparent,
      icon: MacosIcon(icon, color: MacosColors.systemGrayColor.darkColor),
      onPressed: onPressed,
    );
  }
}
