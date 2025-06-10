import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

final class SingleTextField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final Widget? leading;

  const SingleTextField({
    super.key,
    required this.initialValue,
    this.leading,
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
    return MacosTextField(
      controller: _controller,
      prefix: widget.leading,
      style: typography.subheadline,
      onChanged: widget.onChanged,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
