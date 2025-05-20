import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

final class LinkedTextField extends StatefulWidget {
  final String label;
  final TextDataSource dataSource1;
  final TextDataSource dataSource2;

  const LinkedTextField({
    super.key,
    required this.label,
    required this.dataSource1,
    required this.dataSource2,
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
    _controller1 = TextEditingController(text: widget.dataSource1.text);
    _controller2 = TextEditingController(text: widget.dataSource2.text);
    isExpanded = widget.dataSource1.text != widget.dataSource2.text;
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
                  prefix: isExpanded ? widget.dataSource1.description : null,
                ),
                if (isExpanded)
                  MacosTextField(
                    controller: _controller2,
                    prefix: isExpanded ? widget.dataSource2.description : null,
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
                    MacosIconButton(
                      icon: MacosIcon(
                        color: MacosColors.systemGrayColor.darkColor,
                        isExpanded
                            ? CupertinoIcons.chevron_down
                            : CupertinoIcons.chevron_up,
                      ),
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

abstract interface class TextDataSource {
  Widget get description;
  String get text;
  set text(String value);
}
