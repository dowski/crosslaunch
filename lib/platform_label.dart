import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:macos_ui/macos_ui.dart';

final class PlatformLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const PlatformLabel._({super.key, required this.icon, required this.label});

  const PlatformLabel.android({Key? key, required String label})
    : this._(key: key, icon: Icons.android, label: label);

  const PlatformLabel.ios({Key? key, required String label})
    : this._(key: key, icon: Icons.apple, label: label);

  @override
  Widget build(BuildContext context) {
    final secondaryTypography = MacosTypography(
      color:
          MacosTheme.brightnessOf(context).isDark
              ? MacosColors.secondaryLabelColor.darkColor
              : MacosColors.secondaryLabelColor,
    );
    return Row(
      children: [
        MacosIcon(icon),
        const SizedBox(width: 8),
        Text(label, style: secondaryTypography.caption1),
      ],
    );
  }
}
