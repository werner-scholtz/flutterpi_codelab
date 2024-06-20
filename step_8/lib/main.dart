import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:dart_periphery/dart_periphery.dart';

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
const int rtcBusNumber = 1;

/// The address of the rtc [I2C] device.
const int rtcAddress = 0x68;

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GpioChip _chip;
  late final GpioLine _ledLine;
  late final GpioLine _buttonLine;
  late final PWM _pwm;
  late final I2C _i2c;

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
        // Falling means that the voltage on the line has dropped from high to low.
        SignalEdge.falling,
      },
    );

    // Listen for signal events on the _buttonLine.
    _buttonLine.onEvent.listen(
      (event) {
        if (event.edge == SignalEdge.rising) {
          _updateLED(!_ledState);
        }
      },
    );

    // Create a new PWM instance.
    _pwm = PWM(pwmChip, pwmChannel);

    // Set the period of the PWM signal.
    _pwm.setPeriod(_periodSeconds);

    // Set the duty cycle of the PWM signal.
    _pwm.setDutyCycle(_dutyCycle);

    // Enable the PWM signal.
    _pwm.enable();

    _i2c = I2C(1);
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
            title: const Text('PWM duty cycle'),
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
          ElevatedButton(
            child: const Text("its me"),
            onPressed: () {
              _i2c.writeByte(rtcAddress, 0);

              final bytes = _i2c.readBytes(rtcAddress, 7);
              print(bytes);
            },
          ),
        ],
      ),
    );
  }
}
