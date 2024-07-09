import 'package:flutter/material.dart';
import 'package:flutterpi_codelab/src/ds1307.dart';

class RealTimeClockWidget extends StatefulWidget {
  final DS1307 rtc;

  const RealTimeClockWidget({
    super.key,
    required this.rtc,
  });

  @override
  State<RealTimeClockWidget> createState() => _RealTimeClockWidgetState();
}

class _RealTimeClockWidgetState extends State<RealTimeClockWidget> {
  /// The [DateTime] read from the [DS1307].
  DateTime? _rtcTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(_rtcTime?.toString() ?? '-'),
          subtitle: const Text('RTC Time'),
          trailing: FilledButton.icon(
            onPressed: _readRTC,
            label: const Text('Read RTC'),
            icon: const Icon(Icons.download),
          ),
        ),
        ListTile(
          title: const Text('Change date'),
          trailing: FilledButton.icon(
            onPressed: _changeDate,
            label: const Text('Pick Date'),
            icon: const Icon(Icons.date_range_outlined),
          ),
        ),
        ListTile(
          title: const Text('Change time'),
          trailing: FilledButton.icon(
            onPressed: _changeTime,
            label: const Text('Pick Time'),
            icon: const Icon(Icons.date_range_outlined),
          ),
        ),
      ],
    );
  }

  /// Read the [DateTime] from the [DS1307].
  void _readRTC() {
    setState(() {
      _rtcTime = widget.rtc.read();
    });
  }

  /// Adjust the date on the [DS1307].
  void _changeDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2999),
    );
    if (date == null) return;
    final rtcTime = widget.rtc.read();
    if (rtcTime == null) return;

    widget.rtc.adjust(
      date.copyWith(
        hour: rtcTime.hour,
        minute: rtcTime.minute,
        second: rtcTime.second,
      ),
    );
  }

  /// Adjust the time on the [DS1307].
  void _changeTime() async {
    final rtcTime = widget.rtc.read();
    if (rtcTime == null) return;

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(rtcTime),
    );

    if (timeOfDay == null) return;

    widget.rtc.adjust(rtcTime.copyWith(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
    ));
  }
}
