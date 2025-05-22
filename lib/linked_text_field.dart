import 'package:crosslaunch/macos_ui.dart';
import 'package:crosslaunch/platform_label.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

final class LinkedTextField extends StatefulWidget {
  final String label;
  final DataDescriptor dataDescriptor1;
  final DataDescriptor dataDescriptor2;
  final ValueChanged<String>? onChanged;

  const LinkedTextField({
    super.key,
    required this.label,
    required this.dataDescriptor1,
    required this.dataDescriptor2,
    this.onChanged,
  });

  @override
  State<LinkedTextField> createState() => _LinkedTextFieldState();
}

class _LinkedTextFieldState extends State<LinkedTextField> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController(text: widget.dataDescriptor1.value);
    _controller2 = TextEditingController(text: widget.dataDescriptor2.value);
    isExpanded = widget.dataDescriptor1.value != widget.dataDescriptor2.value;
  }

  @override
  void didUpdateWidget(covariant LinkedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dataDescriptor1.value != _controller1.text) {
      _controller1.text = widget.dataDescriptor1.value;
    }
    if (widget.dataDescriptor2.value != _controller2.text) {
      _controller2.text = widget.dataDescriptor2.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Text(widget.label, style: typography.subheadline)],
            ),
          ),
          SizedBox(width: 2),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                MacosTextField(
                  controller: _controller1,
                  style: typography.subheadline,
                  prefix: isExpanded ? widget.dataDescriptor1.label : null,
                  onChanged: widget.onChanged,
                ),
                if (isExpanded)
                  MacosTextField(
                    controller: _controller2,
                    style: typography.subheadline,
                    prefix: isExpanded ? widget.dataDescriptor2.label : null,
                    onChanged: widget.onChanged,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MutedMacosIconButton(
                      icon:
                          isExpanded
                              ? CupertinoIcons.chevron_down
                              : CupertinoIcons.chevron_up,
                      onPressed: () => setState(() => isExpanded = !isExpanded),
                    ),
                    HelpButton(onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }
}

final class DataDescriptor {
  final Widget label;
  final String value;

  DataDescriptor.android(String text, {required this.value})
    : label = PlatformLabel.android(label: text);
  DataDescriptor.ios(String text, {required this.value})
    : label = PlatformLabel.ios(label: text);
}
