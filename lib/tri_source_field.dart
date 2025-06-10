import 'package:crosslaunch/macos_ui.dart';
import 'package:crosslaunch/platform_label.dart';
import 'package:crosslaunch/single_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class TriSourceTextField extends StatefulWidget {
  final bool isExpanded;
  final String mainFieldLabel;
  final ValueChanged<String>? onMainFieldChanged;
  final String? mainFieldValue;
  final Widget? mainFieldTrailing;
  final String androidLabel;
  final String? androidValue;
  final ValueChanged<String>? onAndroidChanged;
  final String iosLabel;
  final String? iosValue;
  final ValueChanged<String>? onIosChanged;

  const TriSourceTextField({
    super.key,
    this.isExpanded = false,
    required this.mainFieldLabel,
    this.onMainFieldChanged,
    this.mainFieldValue,
    this.mainFieldTrailing,
    required this.androidLabel,
    this.androidValue,
    this.onAndroidChanged,
    required this.iosLabel,
    this.iosValue,
    this.onIosChanged,
  });

  @override
  State<StatefulWidget> createState() => _TriSourceTextFieldState();
}

class _TriSourceTextFieldState extends State<TriSourceTextField> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.mainFieldLabel,
              textAlign: TextAlign.end,
              style: typography.subheadline,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SingleTextField(
                initialValue: widget.mainFieldValue ?? '',
                onChanged: widget.onMainFieldChanged,
              ),
              if (isExpanded) ...[
                const SizedBox(height: 8),
                SingleTextField(
                  initialValue: widget.androidValue ?? '',
                  leading: PlatformLabel.android(label: widget.androidLabel),
                  onChanged: widget.onAndroidChanged,
                ),
                const SizedBox(height: 8),
                SingleTextField(
                  initialValue: widget.iosValue ?? '',
                  leading: PlatformLabel.ios(label: widget.iosLabel),
                  onChanged: widget.onIosChanged,
                ),
              ],
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: Row(
            children: [
              MutedMacosIconButton(
                icon:
                    isExpanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                onPressed: () => setState(() => isExpanded = !isExpanded),
              ),
              if (widget.isExpanded) const _WarningWidget(),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarningWidget extends StatelessWidget {
  const _WarningWidget();

  @override
  Widget build(BuildContext context) {
    return MacosIcon(
      CupertinoIcons.exclamationmark_circle,
      color: MacosColors.systemYellowColor.darkColor,
    );
  }
}
