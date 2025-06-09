import 'package:crosslaunch/macos_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

typedef OnTextChange<T extends DataDescriptor> =
    void Function(String value, bool isCollapsed, T descriptor);

final class LinkedTextField<T extends DataDescriptor> extends StatefulWidget {
  final String label;
  final T dataDescriptor1;
  final T dataDescriptor2;
  final OnTextChange<T>? onChanged;

  const LinkedTextField({
    super.key,
    required this.label,
    required this.dataDescriptor1,
    required this.dataDescriptor2,
    this.onChanged,
  });

  @override
  State<LinkedTextField<T>> createState() => _LinkedTextFieldState<T>();
}

class _LinkedTextFieldState<T extends DataDescriptor>
    extends State<LinkedTextField<T>> {
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
  void didUpdateWidget(covariant LinkedTextField<T> oldWidget) {
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
                  onChanged:
                      widget.onChanged == null
                          ? null
                          : (value) => widget.onChanged!(
                            value,
                            !isExpanded,
                            widget.dataDescriptor1,
                          ),
                ),
                if (isExpanded)
                  MacosTextField(
                    controller: _controller2,
                    style: typography.subheadline,
                    prefix: isExpanded ? widget.dataDescriptor2.label : null,
                    onChanged:
                        widget.onChanged == null
                            ? null
                            : (value) => widget.onChanged!(
                              value,
                              !isExpanded,
                              widget.dataDescriptor2,
                            ),
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
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
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

abstract interface class DataDescriptor {
  Widget get label;
  String get value;
}
