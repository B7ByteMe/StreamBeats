import 'package:streambeats/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StreamBeatsSwitch extends StatefulWidget {
  final bool value;
  final VoidCallback onChanged;

  const StreamBeatsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<StreamBeatsSwitch> createState() => _StreamBeatsSwitchState();
}

class _StreamBeatsSwitchState extends State<StreamBeatsSwitch> {
  late bool _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant StreamBeatsSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _localValue = widget.value;
    }
  }

  void _handleTap() {
    setState(() {
      _localValue = !_localValue;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: _localValue
              ? Default_Theme.accentColor2.withValues(alpha: 0.15)
              : Default_Theme.primaryColor2.withValues(alpha: 0.05),
          border: Border.all(
            color: _localValue
                ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                : Default_Theme.primaryColor2.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: _localValue ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _localValue
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor2.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}