import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutterpi_codelab/ds1307.dart';

/// The label of the [GpioChip] that the LED is connected to.
const String gpioChipLabel = 'pinctrl-bcm2835';

/// The name of the [GpioLine]  that the LED is connected to.
const String ledGpioLineName = 'GPIO23';

/// The name of the [GpioLine] that the button is connected to.
const String buttonGpioLineName = 'GPIO24';

/// The [PWM] chip number.
const int pwmChip = 0;

/// The [PWM] channel number.
const int pwmChannel = 0;

/// The bus number of the rtc [I2C] device.
const int i2cBus = 1;

void main() {
  // Set the libperiphery.so path.
  setCustomLibrary("/usr/local/lib/libperiphery.so");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pi Codelab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// The GPIO chip that the LED is connected to.
  late final GpioChip _chip;

  /// The GPIO line that the LED is connected to.
  late final GpioLine _ledLine;

  /// The GPIO line that the button is connected to.
  late final GpioLine _buttonLine;

  /// The PWM instance. (With the chip number and channel number set to where the LED is connected)
  late final PWM _pwm;

  /// The I2C instance on the bus where the RTC module is connected.
  late final I2C _i2c;

  /// The RTC instance.
  late final DS1307 _rtc;

  /// The update frequency of the system time.
  final _systemTimerFrequency = const Duration(milliseconds: 100);

  /// The timer that updates the system time.
  late final Timer _systemTimeUpdateTimer;

  /// The update frequency of the RTC time.
  final _rtcTimerFrequency = const Duration(seconds: 1);

  /// The timer that updates the RTC time.
  late final Timer _rtcTimeUpdateTimer;

  /// A [ValueNotifier] that holds the system's [DateTime].
  late final ValueNotifier<DateTime> _systemTime;

  /// A [ValueNotifier] that holds the RTC's [DateTime].
  late final ValueNotifier<DateTime> _rtcTime;

  /// The state of the LED. (true = on, false = off)
  bool _ledState = false;

  /// The period of the PWM signal in seconds.
  final double _periodSeconds = 0.005;

  /// The duty cycle, this is the amount of time the signal is high compared to the period.
  double _dutyCycle = 0.5;

  @override
  void initState() {
    super.initState();

    // Retrieve a list of GPIO chips attached to the system.
    final chips = FlutterGpiod.instance.chips;

    // Find the GPIO chip with the label _gpioChipLabel.
    _chip = chips.singleWhere((chip) {
      return chip.label == gpioChipLabel;
    });

    // Find the GPIO line with the name _ledGpioLineName.
    _ledLine = _chip.lines.singleWhere((line) {
      return line.info.name == ledGpioLineName;
    });

    // Request control of the GPIO line. (Because we are using the line as an output use the requestOutput method.)
    _ledLine.requestOutput(
      consumer: 'flutterpi_codelab',
      initialValue: _ledState,
    );

    // Find the GPIO line with the name _buttonGpioLineName.
    _buttonLine = _chip.lines.singleWhere((line) {
      return line.info.name == buttonGpioLineName;
    });

    // Request control of the _buttonLine. (Because we are using the line as an input use the requestInput method.)
    _buttonLine.requestInput(
      consumer: 'flutterpi_codelab',
      // Listen for both rising and falling edge signals.
      triggers: {
        // Rising means that the voltage on the line has risen from low to high.
        SignalEdge.rising,
      },
    );

    // Listen for signal events on the _buttonLine.
    _buttonLine.onEvent.listen(
      (event) => _updateLED(!_ledState),
    );

    // Create a new PWM instance.
    _pwm = PWM(pwmChip, pwmChannel);

    // Set the period of the PWM signal.
    _pwm.setPeriod(_periodSeconds);

    // Set the duty cycle of the PWM signal.
    _pwm.setDutyCycle(_dutyCycle);

    // Enable the PWM signal.
    _pwm.enable();

    // Create a new I2C instance on bus 1.
    _i2c = I2C(i2cBus);

    // Create a new TinyRTC instance.
    _rtc = DS1307(_i2c);

    final now = DateTime.now();
    _rtc.adjust(now);

    // Initialize the ValueNotifiers.
    _systemTime = ValueNotifier(now);
    _rtcTime = ValueNotifier(now);

    // Adjust the RTC to the current date and time.

    _systemTimeUpdateTimer = Timer.periodic(_systemTimerFrequency, (timer) {
      // Read the current system DateTime.
      final systemDateTime = DateTime.now();

      // Update the UI.
      _systemTime.value = systemDateTime;
    });

    _rtcTimeUpdateTimer = Timer.periodic(_rtcTimerFrequency, (timer) {
      // Read the current RTC DateTime.
      final rtcDateTime = _rtc.read();

      // Update the UI.
      _rtcTime.value = rtcDateTime ?? _rtcTime.value;
    });
  }

  @override
  void dispose() {
    // Release control of the GPIO line.
    _ledLine.release();
    _buttonLine.release();

    // Disable the PWM signal.
    _pwm.disable();

    // Dispose of the PWM instance.
    _pwm.dispose();

    // Dispose of the I2C instance.
    _i2c.dispose();

    // Cancel the timers.
    _systemTimeUpdateTimer.cancel();
    _rtcTimeUpdateTimer.cancel();

    super.dispose();
  }

  void _updateLED(bool value) {
    // Update the UI.
    setState(() {
      _ledState = value;
    });

    // Set the value of the GPIO line to the new state.
    _ledLine.setValue(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Pi Codelab')),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('LED Switch'),
            value: _ledState,
            onChanged: (value) => _updateLED(value),
          ),
          ListTile(
            title: const Text('PWM Duty Cycle'),
            subtitle: Slider(
              min: 0,
              max: 1,
              value: _dutyCycle,
              onChanged: (value) {
                // Update the UI.
                setState(() {
                  _dutyCycle = value;
                });

                // Set the duty cycle of the PWM signal.
                _pwm.setDutyCycle(value);
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _systemTime,
            builder: (context, value, child) {
              return ListTile(
                title: Text(value.toString()),
                subtitle: const Text('System Time'),
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: _rtcTime,
            builder: (context, value, child) {
              return ListTile(
                title: Text(value.toString()),
                subtitle: const Text('RTC Time'),
              );
            },
          ),
        ],
      ),
    );
  }
}
