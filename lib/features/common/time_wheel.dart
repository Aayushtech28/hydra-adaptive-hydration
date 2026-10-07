import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../core/units/formatters.dart';

/// Inline wheel time picker (minutes after midnight) with a large readable
/// value for screen readers and a text fallback via the semantics label.
class TimeWheel extends StatelessWidget {
  const TimeWheel({
    super.key,
    required this.minute,
    required this.onChanged,
    required this.locale,
    this.semanticsLabel,
  });

  final int minute;
  final ValueChanged<int> onChanged;
  final String locale;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.hx;
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    return Semantics(
      label: '${semanticsLabel ?? ''} ${Formatters.minuteOfDay(minute, locale, use24h: use24)}',
      child: SizedBox(
        height: 190,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Theme.of(context).brightness,
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: context.text.headlineSmall?.copyWith(color: t.ink),
            ),
          ),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            use24hFormat: use24,
            minuteInterval: 5,
            initialDateTime: DateTime(2000, 1, 1, minute ~/ 60, minute % 60),
            onDateTimeChanged: (d) => onChanged(d.hour * 60 + d.minute),
          ),
        ),
      ),
    );
  }
}
