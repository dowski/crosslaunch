import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

final class SingleTextField extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  const SingleTextField({
    super.key,
    required this.label,
    required this.initialValue,
    this.onChanged,
  });

  @override
  State<SingleTextField> createState() => _SingleTextFieldState();
}

class _SingleTextFieldState extends State<SingleTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant SingleTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
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
          const SizedBox(width: 2),
          Expanded(
            flex: 4,
            child: MacosTextField(
              controller: _controller,
              style: typography.subheadline,
              onChanged: widget.onChanged == null
                  ? null : (value) => widget.onChanged!(value),
            ),
          ),
          const Expanded(flex: 1, child: SizedBox.shrink()), // Placeholder for alignment
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}