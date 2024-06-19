import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';

/// The label of the [GpioChip] that the LED is connected to.
const String _gpioChipLabel = 'pinctrl-bcm2835';

/// The name of the [GpioLine]  that the LED is connected to.
const String _ledGpioLineName = 'GPIO23';

/// The name of the [GpioLine] that the button is connected to.
const String _buttonGpioLineName = 'GPIO24';

void main() {
  final chips = FlutterGpiod.instance.chips;
  for (final chip in chips) {
    print("chip name: ${chip.name}, chip label: ${chip.label}");
    for (final line in chip.lines) {
      print("  line: $line");
    }
  }
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
  late final GpioChip? _chip;
  late final GpioLine? _ledLine;
  late final GpioLine? _buttonLine;

  /// The state of the LED. (true = on, false = off)
  bool _ledState = false;

  @override
  void initState() {
    super.initState();

    // Retrieve a list of GPIO chips attached to the system.
    final chips = FlutterGpiod.instance.chips;

    // Find the GPIO chip with the label _gpioChipLabel.
    _chip = chips.where((chip) {
      return chip.label == _gpioChipLabel;
    }).firstOrNull;

    // Find the GPIO line with the name _ledGpioLineName.
    _ledLine = _chip?.lines.where((line) {
      return line.info.name == _ledGpioLineName;
    }).firstOrNull;

    // Request control of the GPIO line. (Because we are using the line as an output use the requestOutput method.)
    _ledLine?.requestOutput(
      consumer: 'flutterpi_codelab',
      initialValue: _ledState,
    );

    // Find the GPIO line with the name _buttonGpioLineName.
    _buttonLine = _chip?.lines.where((line) {
      return line.info.name == _buttonGpioLineName;
    }).firstOrNull;

    // Request control of the _buttonLine. (Because we are using the line as an input use the requestInput method.)
    _buttonLine?.requestInput(
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
    _buttonLine?.onEvent.listen(
      (event) {
        if (event.edge == SignalEdge.rising) {
          _updateLED(!_ledState);
        }
      },
    );
  }

  @override
  void dispose() {
    // Release control of the GPIO line.
    _ledLine?.release();
    _buttonLine?.release();
    super.dispose();
  }

  void _updateLED(bool value) {
    setState(() {
      _ledState = value;
      _ledLine?.setValue(value);
    });
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
        ],
      ),
    );
  }
}
