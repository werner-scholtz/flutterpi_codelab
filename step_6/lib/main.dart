import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:dart_periphery/dart_periphery.dart';

/// The name of the [GpioChip] that the LED is connected to.
const String gpioChipName = 'gpiochip0';

/// The name of the [GpioLine]  that the LED is connected to.
const String ledGpioLineName = 'GPIO23';

/// The name of the [GpioLine] that the button is connected to.
const String buttonGpioLineName = 'GPIO24';

/// The [PWM] chip number.
const int pwmChip = 0;

/// The [PWM] channel number.
const int pwmChannel = 0;

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

  /// The state of the LED. (true = on, false = off)
  bool _ledState = false;

  /// The period of the PWM signal in seconds.
  final double _periodSeconds = 0.01;

  /// The duty cycle, this is the amount of time the signal is high compared to the period.
  double _dutyCycle = 0.5;

  @override
  void initState() {
    super.initState();

    // Retrieve a list of GPIO chips attached to the system.
    final chips = FlutterGpiod.instance.chips;

    // Find the GPIO chip with the label _gpioChipLabel.
    _chip = chips.singleWhere((chip) {
      return chip.name == gpioChipName;
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
      triggers: {
        // Rising means that the voltage on the line has risen from low to high.
        SignalEdge.rising,
        // Falling means that the voltage on the line has dropped from high to low.
        SignalEdge.falling,
      },
    );

    // Listen for signal events on the _buttonLine.
    _buttonLine.onEvent.listen((event) {
      switch (event.edge) {
        case SignalEdge.rising:
          _updateLED(true);
          break;
        case SignalEdge.falling:
          _updateLED(false);
          break;
      }
    });

    // Create a new PWM instance.
    _pwm = PWM(pwmChip, pwmChannel);

    // Set the period of the PWM signal.
    _pwm.setPeriod(_periodSeconds);

    // Set the duty cycle of the PWM signal.
    _pwm.setDutyCycle(_dutyCycle);

    // Enable the PWM signal.
    _pwm.enable();
  }

  @override
  void dispose() {
    // Release control of the GPIO line(s).
    _ledLine.release();
    _buttonLine.release();

    // Disable the PWM signal.
    _pwm.disable();
    // Dispose of the PWM instance.
    _pwm.dispose();

    super.dispose();
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
            onChanged: _updateLED,
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
        ],
      ),
    );
  }

  void _updateLED(value) {
    setState(() {
      // Update the state of the LED.
      _ledState = value;
    });

    // Set the value of the GPIO line to the new state.
    _ledLine.setValue(value);
  }
}
