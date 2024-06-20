import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';

/// The label of the GPIO chip that the LED is connected to.
const String gpioChipLabel = 'pinctrl-bcm2835';

/// The name of the GPIO line that the LED is connected to.
const String ledGpioLineName = 'GPIO23';

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
  late final GpioChip _chip;
  late final GpioLine _ledLine;

  /// The state of the LED. (true = on, false = off)
  bool _ledState = false;

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
      initialValue: false,
    );
  }

  @override
  void dispose() {
    // Release control of the GPIO line.
    _ledLine.release();
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
            onChanged: (value) {
              setState(() {
                // Update the state of the LED.
                _ledState = value;

                // Set the value of the GPIO line to the new state.
                _ledLine.setValue(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
