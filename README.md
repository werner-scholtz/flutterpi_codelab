# Getting started with flutter-pi

## What you'll build

In this codelab you are going to build a flutter app that runs on a Raspberry Pi, using a custom-embedder called [flutter-pi](https://github.com/ardera/flutter-pi)

Your app will be able to:  
1. Turn an LED on/off using [GPIO](https://en.wikipedia.org/wiki/General-purpose_input/output).  
2. Detect a button press with [GPIO](https://en.wikipedia.org/wiki/General-purpose_input/output).
3. Dim a LED with [PWM](https://en.wikipedia.org/wiki/Pulse-width_modulation).  
4. Read the time from an [RTC](https://en.wikipedia.org/wiki/Real-time_clock) module using [I2C](https://en.wikipedia.org/wiki/I%C2%B2C).  

## What you'll learn

- How to run a flutter app on your Pi using flutter-pi.  
- How to use GPIO in flutter/dart.  
- How to use PWM in flutter/dart.
- How to use I2C in flutter/dart.

This codelab is focused on flutter and flutter-pi. Non-relevant concepts and code blocks are glossed over and are provided for you to simply copy and paste.

## What you'll need

### Required 

- Raspberry Pi (3, 4 or Pi Zero 2 (W))
- [Breadboard](https://en.wikipedia.org/wiki/Breadboard).
- [LED](https://en.wikipedia.org/wiki/Light-emitting_diode).
- 330 ohm [resistor](https://en.wikipedia.org/wiki/Resistor).
- [Jump wires](https://en.wikipedia.org/wiki/Jump_wire).  

**_NOTE:_** A resistor with a resistance from *330* to *1000* ohms will also work. (This is just to protect the LED).

### Optional 

- Tactile switch/[Push button](https://en.wikipedia.org/wiki/Push-button).
- [DS1307 Real Time Clock](https://www.adafruit.com/product/3296) module.  

**_NOTE:_** If you do not have some of the components you can just skip the section of the codelab.

# 1. Setup your development environment

## Setup flutter

1. [Install flutter](https://docs.flutter.dev/get-started/install) on your development machine.

## Setup your Pi

1. [Install Raspberry Pi OS](https://www.raspberrypi.com/software/) on your Pi.

**_NOTE:_** If this is your first time setting up a Pi see [this](https://www.raspberrypi.com/documentation/computers/remote-access.html) on how to use ssh for remote control of your pi.

## Setup flutter-pi

1. Setup flutter-pi by following these [instructions](https://github.com/ardera/flutter-pi?tab=readme-ov-file#-building-flutter-pi-on-the-raspberry-pi).
2. Configure your Pi by following these [instructions](https://github.com/ardera/flutter-pi?tab=readme-ov-file#-running-your-app-on-the-raspberry-pi)
.

# 2. Run a flutter app on your Pi with flutter-pi

## Create a new flutter app

1. `flutter create flutter_pi_codelab`
2. Open the project in your favorite IDE.

## Run the app on your Pi

### Recommended

1. Install [flutterpi_tool](https://pub.dev/packages/flutterpi_tool/install).
2. Follow these [instructions](https://github.com/ardera/flutterpi_tool?tab=readme-ov-file#examples) to add your Pi as a device.
3. Then do `flutterpi_tool run -d <device-id>`.


### Workarounds

#### Linux

1. If you get the following error on linux after running `flutterpi_tool run -d <device-id>`.
  ```
  ProcessException: Process exited abnormally with code 126
  Command: /tmp/flutterpi_codelab/flutter-pi /tmp/flutterpi_codelab --enable-dart-profiling=true --enable-checked-mode=true --verify-entry-points=true --vm-service-port=33895
  ```
2. You can run the following command, this makes the flutter-pi binary executable.  
  You can find the binary under `build/flutter-pi/../flutter-pi`

```shell
sudo chmod +x build/flutter-pi/aarch64-generic/flutter-pi 
```

# 3. Control an LED with GPIO

Find out about [General-purpose input/output](https://en.wikipedia.org/wiki/General-purpose_input/output).

## Connect the LED to your Pi

First you need to connect the LED to your Pi’s GPIO Header. You can have a look at the  [documentation](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#gpio) to find a GPIO pin that will work for you.

![40-Pin Header](https://www.raspberrypi.com/documentation/computers/images/GPIO-Pinout-Diagram-2.png?hash=df7d7847c57a1ca6d5b2617695de6d46)
**(40-Pin Header. https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#gpio)**  

For this example I will be using GPIO23 but you can use any other GPIO pin. You should add a resistor to limit the amount of current flowing through the LED. In this example I’m using a 330-ohm resistor in series with the LED.

![LED Schematic](https://github.com/werner-scholtz/flutterpi_codelab/blob/main/assets/led_schematic.png?raw=true)

**(LED Schematic)**  

## Control the LED

You will be using [flutter_gpiod](https://pub.dev/packages/flutter_gpiod) to control the LED.
1. Add flutter_gpiod to your app with: `flutter pub add flutter_gpiod`
2. Import flutter_gpiod in your main.dart `import 'package:flutter_gpiod/flutter_gpiod.dart';`

flutter_gpiod has a very useful way to find the correct GPIO pin in your app.You can list all available GPIO chips along with their GPIO lines/pins by running the following code in your `main` method:

```dart
final chips = FlutterGpiod.instance.chips;
for (final chip in chips) {
  print("chip name: ${chip.name}, chip label: ${chip.label}");
  for (final line in chip.lines) {
    print("  line: $line");
  }
}
```

When starting your app you can expect the above code to print something like this:

```
chip name: gpiochip0, chip label: pinctrl-bcm2835
   line: GpioLine(info: LineInfo(name: 'ID_SDA', consumer: '', direction:  input, bias:  disable, isUsed: false, isRequested: false, isFree: true))
   line: GpioLine(info: LineInfo(name: 'ID_SCL', consumer: '', direction:  input, bias:  disable, isUsed: false, isRequested: false, isFree: true))
   line: GpioLine(info: LineInfo(name: 'GPIO2', consumer: '', direction:  input, bias:  disable, isUsed: false, isRequested: false, isFree: true))
   ...
   line: GpioLine(info: LineInfo(name: 'GPIO23', consumer: '', direction:  input, bias:  disable, isUsed: false, isRequested: false, isFree: true))
 chip name: gpiochip1, chip label: raspberrypi-exp-gpio
   line: GpioLine(info: LineInfo(name: 'BT_ON', consumer: 'shutdown', direction: output, bias:  disable, isUsed: true, isRequested: false, isFree: false))
   line: GpioLine(info: LineInfo(name: 'WL_ON', consumer: '', direction: output, bias:  disable, isUsed: false, isRequested: false, isFree: true))
   ...

```

**_NOTE:_** Taking a loot at the output from this command it is easy to deduce which chip to use in this case GPIO23 is connected to gpiochip0.

Define two global variables `_gpioChipName` and `_gpioLineName` in your main.dart.
```dart
/// The name of the GPIO chip that the LED is connected to.
const String gpioChipName = 'gpiochip0';

/// The name of the GPIO line that the LED is connected to.
const String ledGpioLineName = 'GPIO23';
```

Define two new variables in `MyHomePage` `_chip` and `_ledLine`.

```dart
/// The GPIO chip that the LED is connected to.
late final GpioChip _chip;

/// The GPIO line that the LED is connected to.
late final GpioLine _ledLine;
```

Now in your init state you want to assign the chip and line to the variables.

```dart
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
}
```

Following [flutter_gpiod](https://pub.dev/packages/flutter_gpiod#getting-started)’s example for controlling a GPIO line you first need to request ownership of it, as we will be switching an led on/off we need to request it as an output, you can do this by calling the `requestOutput()` method on the `_ledLine` in initState().

- The `consumer` parameter is in essence just a debug label that you can use to identify who is using the GPIO line.
- The `initialValue` parameter is the initial value of the GPIO line, in this case, we want the LED to be off initially so we set it to `false`.

```dart
// Request control of the GPIO line as an output.
_ledLine.requestOutput(
  consumer: 'flutterpi_codelab',
  initialValue: false,
);
```

Holdup you also need to release ownership of the `_ledLine` when you are done using it, so use the `release()` method on the `_ledLine` in the `dispose()` method.

```dart
// Release control of the GPIO line.
_ledLine.release();
```

Now create a `SwitchListTile` to turn the button on/off. For this you will need to create a boolean `_ledState` so the `SwitchListTile` knows in what state the LED is in.

```dart
/// The state of the LED. (true = on, false = off)
bool _ledState = false;

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
            });

            // Set the value of the GPIO line to the new state.
            _ledLine.setValue(value);
          },
        ),
      ],
    ),
  );
}
```

Now you can start your app and turn the LED on/off by toggling the `SwitchListTile`.

**_NOTE:_** Because flutter_gpiod and hot-restart does not play nice you will need to do a full restart of the app otherwise you might get an error related to the GPIO line being in use.

Because you will be turning the led on/off later in this codelab, extract the onChanged() method into a separate function.

```dart
void _updateLED(value) {
  setState(() {
    // Update the state of the LED.
    _ledState = value;
  });

  // Set the value of the GPIO line to the new state.
  _ledLine.setValue(value);
}
```

Also update the requestOutput() method to set the initial value of the LED.

```dart
_ledLine?.requestOutput(
  consumer: 'flutterpi_codelab',
  initialValue: _ledState,
);
```

# 4. Detect a button press with GPIO

## Connect the Button to your Pi

Decide which GPIO pin you want to use for the button in this example GPIO24 will be used, and connect your button to it as shown in the schematic below.

![Button Schematic](https://github.com/werner-scholtz/flutterpi_codelab/blob/main/assets/button_schematic.png?raw=true)

**(Button Schematic)**

## Detect the button press

Start by adding a new global variable `_buttonGpioLineName` that matches the name of the GPIO pin you want to use. 

```dart
/// The name of the [GpioLine] that the button is connected to.
const String buttonGpioLineName = 'GPIO24';
```

Define a new variable `_buttonLine` in `MyHomePage`.

```dart
/// The GPIO line that the button is connected to.
late final GpioLine _buttonLine;
```

In the `initState()` method assign the chip and line to the variables.

```dart
// Find the GPIO line with the name _buttonGpioLineName.
_buttonLine = _chip.lines.singleWhere((line) {
  return line.info.name == buttonGpioLineName;
});
```

Next you need to request ownership of it, in this case you are going to use it as an input, and request ownership with the `requestInput()` method on the `_buttonLine`. The request input has a `triggers` parameter, this is what will determine if the `_buttonLine.onEvent` stream will emit an event. You have the choice of one or both of the following triggers:

```dart
// Rising means that the voltage on the line has risen from low to high.
SignalEdge.rising;

// Falling means that the voltage on the line has dropped from high to low.
SignalEdge.falling;
```

You can now request the GPIOline as an input with the following code:

```dart
// Request control of the _buttonLine. (Because we are using the line as an input use the requestInput method.)
_buttonLine.requestInput(
  consumer: 'flutterpi_codelab',
  triggers: {
    SignalEdge.rising,
    SignalEdge.falling,
  },
);
```

And release the line in the `dispose()` method of the `MyHomePage`.

```dart
_buttonLine.release();
```

You can now listen to the `_buttonLine.onEvent` and print the event in the console, by adding this to your `initState()` method:

```dart
// Listen for signal events on the _buttonLine.
_buttonLine.onEvent.listen(
  (event) => print(event),
);
```

Make sure that you are detecting the button press by restarting the app and pressing the button, you should see the event being printed in the console. (If now make sure the button is connected correctly).
```
signal event SignalEvent(edge: falling, timestamp: 0:37:03.476893, time: 2024-06-19 14:39:20.301019)
signal event SignalEvent(edge: rising, timestamp: 0:37:03.564660, time: 2024-06-19 14:39:20.388289)
signal event SignalEvent(edge: falling, timestamp: 0:37:04.507935, time: 2024-06-19 14:39:21.331576)
```

Now that you are detecting the button press you can use it to turn the LED on/off. You can do this by updating the `_buttonLine.onEvent.listen()` method to toggle the LED on/off when the button is pressed.

```dart
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
```

Now restart your app and you should now be able to turn the LED on and off using the physical button. (:D)

# 5. Dim a LED with PWM

Find out about [Pulse-width modulation](https://en.wikipedia.org/wiki/Pulse-width_modulation).

## Configuring your Pi

To use PWM you will need to add some lines to the config.txt

1. Open up the config.txt:  
    `sudo nano /boot/firmware/config.txt`
2. Add this line:  
    ```shell
    dtoverlay=pwm,pin=18,func=2
    ```
3. Save and exit the file.
4. Open up 99-com.rules:
    `sudo nano /etc/udev/rules.d/99-com.rules`
5. Add the following lines:
    ```shell
    SUBSYSTEM=="pwm*", PROGRAM="/bin/sh -c '\
            chown -R root:gpio /sys/class/pwm && chmod -R 770 /sys/class/pwm;\
            chown -R root:gpio /sys/devices/platform/soc/*.pwm/pwm/pwmchip* && chmod -R 770 /sys/devices/platform/soc/*.pwm/pwm/pwmchip*\
    '"
    ```
6. Save and exit the file.
7. Reboot your Pi:  
    `sudo reboot`  

**_NOTE:_** If this does not work you check out this [documentation](https://github.com/dotnet/iot/blob/main/Documentation/raspi-pwm.md).

## Installing c-periphery

You will be using [dart_periphery](https://pub.dev/packages/dart_periphery) for this step so add that to you app.
1. Add dart_periphery to your app with: `flutter pub add dart_periphery`
2. Import dart_periphery in your main.dart `import 'package:dart_periphery/dart_periphery.dart';`

In [dart_periphery](https://pub.dev/packages/dart_periphery)’s documentation it says that it makes use of the [c-periphery](https://github.com/vsergeev/c-periphery) library. You will need to use the `setCustomLibrary(String absolutePath)` provided by dart_periphery. To install c-periphery as a shared library on your pi. (see: https://github.com/vsergeev/c-periphery#shared-library)

Quick install guide:
```shell
git clone https://github.com/vsergeev/c-periphery.git
cd c-periphery
mkdir build
cd build
cmake -DBUILD_SHARED_LIBS=ON ..
make
sudo make install
```

This will install the c-periphery on your pi, take note of where it has placed `libperiphery.so`, in the case of the example it has been placed here `/usr/local/lib/libperiphery.so`.

## Connect the LED to your Pi

Now you can wire up the led to ground and the PWM enabled pin. In this example pin `GPIO18` is used.

![PWM Schematic](https://github.com/werner-scholtz/flutterpi_codelab/blob/main/assets/led_pwm_schematic.png?raw=true)

## Dim the LED

Start off by pointing dart_periphery to the library you installed earlier.

```dart
// Set the libperiphery.so path
setCustomLibrary("/usr/local/lib/libperiphery.so");
```

Create two new identifiers for the PWM chip and the PWM channel:

```dart
/// The [PWM] chip number.
const int pwmChip = 0;

/// The [PWM] channel number.
const int pwmChannel = 0;
```
Next add a variable `_pwm` to `MyHomePage`:

```dart
late final PWM _pwm;
```

And assign a PWM instance to the variable in the `initState()` method:

```dart
_pwm = PWM(pwmChip, pwmChannel);
```

Create two variables to define the behavior of the PWM signal:

```dart
/// The period of the PWM signal in seconds.
final  double _periodSeconds = 0.01;

/// The duty cycle, this is the amount of time the signal is high for the given period.
double _dutyCycle = 0.05;
```

Now set up the PWM instance to use the period and duty cycle, in your `initState()` method:

```dart
// Set the period of the PWM signal.
_pwm.setPeriod(_periodSeconds);

// Set the duty cycle of the PWM signal.
_pwm.setDutyCycle(_dutyCycle);

// Enable the PWM signal.
_pwm.enable();
```

Remember to dispose of the PWM instance.  

```dart
_pwm.dispose();
```

Start up the app and you should see that the LED is not as bright as it usually is. (If not make sure the LED is connected correctly).

You can now add a slider to adjust the brightness of the LED:

```dart
ListTile(
  title: const Text('PWM duty cycle'),
  subtitle: Slider(
    min: 0,
    max: 1,
    value: _dutyCycle,
    onChanged: (value) {
      setState(() {
        _dutyCycle = value;
      });

      _pwm.setDutyCycle(value);
    },
  ),
),
```

Restart the app and you are now be able to adjust the brightness of the LED using the slider.

# 6. Read the time from an RTC module (DS1307) using I2C

Find out about [I2C](https://en.wikipedia.org/wiki/I%C2%B2C).

## Configuring your Pi

You will need to enable I2C on your Pi.

1. Run `sudo raspi-config`.
2. Go to `Interfacing Options`.
3. Go to `I2C`.
4. Enable I2C.
5. Reboot your Pi.  
    `sudo reboot`.

**_NOTE:_** If you are running into issues you can check out this [documentation](https://github.com/dotnet/iot/blob/main/Documentation/raspi-i2c.md) and/or this [documentation](https://github.com/fivdi/i2c-bus/blob/master/doc/raspberry-pi-i2c.md).

## Connect the RTC module to your Pi

You can now connect your tiny rtc module according to the schematic below.

![RTC Schematic](https://github.com/werner-scholtz/flutterpi_codelab/blob/main/assets/rtc_schematic.png?raw=true)

## Finding the I2C adaptor

Finding the correct i2c adapter run the following command on your pi `i2cdetect -l` this will return a list of all the I2C adaptors on your device.

```
i2c-1   i2c             bcm2835 (i2c@7e804000)                  I2C adapter
```

You can find out if any I2C devices are connected to an adapter by running `i2cdetect -y <channel number>`, on raspberry pi you would generally use the I2C adaptor 1 which is connected to the GPIO header.

Running `i2cdetect -y 1` will result in something like this:

```
0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:                         -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
50: 50 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- 68 -- -- -- -- -- -- -- 
70: -- -- -- -- -- -- -- --       
```

Check that there is something at address `0x68` this is the default address of the DS1307 chip.

## Reading the time

Because dart_periphery does not support the DS1307 chip (yet), you can use [this](https://github.com/werner-scholtz/flutterpi_codelab/blob/main/step_7/lib/src/ds1307.dart) minimal dart implementation to read/adjust the time on the DS1307 chip.

1. Create a new file `ds1307.dart` in the `lib/src` directory.
2. Copy the code from [here](https://github.com/werner-scholtz/flutterpi_codelab/blob/main/step_7/lib/src/ds1307.dart)
3. Import the file in your main.dart `import 'src/ds1307.dart';`

Create a const value to declare the i2cBus number:
```dart
/// The bus number of the rtc [I2C] device.
const int i2cBus = 1;
```

Create variables for the i2c and DS1307 instances in your `MyHomePage`:
```dart
late final I2C _i2c;
late final DS1307 _rtc;
```

Then instantiate them in your `initState()` method:
```dart
// Create a new I2C instance on bus 1.
_i2c = I2C(i2cBus);

// Create a new TinyRTC instance.
_rtc = DS1307(_i2c);
```

And dispose of the I2C instance in your `dispose()` method:
```dart
// Dispose of the I2C instance.
_i2c.dispose();
```

You can use this widget to read/adjust the time on the DS1307 chip:
1. Create a new file `real_time_clock_widget.dart` in the `lib/src` directory.
2. Copy the code from [here](https://github.com/werner-scholtz/flutterpi_codelab/blob/main/step_7/lib/src/real_time_clock_widget.dart)

Then just add the widget to your `MyHomePage`:

```dart
@override
Widget build(BuildContext context) {
return Scaffold(
    appBar: AppBar(title: const Text('Flutter Pi Codelab')),
    body: ListView(
    children: <Widget>[
        ...
        RealTimeClockWidget(rtc: _rtc),
    ],
    ),
  );
}
```
After restarting the app you are now be able to read/adjust the time on the DS1307 chip.

# References
- Full example: https://github.com/werner-scholtz/flutterpi_codelab/tree/main/step_8  
- flutter-pi: https://github.com/ardera/flutter-pi
- flutterpi_tool: https://github.com/ardera/flutterpi_tool
- flutter custom-devices: https://github.com/flutter/flutter/blob/master/docs/tool/Using-custom-embedders-with-the-Flutter-CLI.md#the-custom-devices-config-file
- flutter_gpiod: https://pub.dev/packages/flutter_gpiod
- dart_periphery: https://pub.dev/packages/dart_periphery
- c-periphery: https://github.com/vsergeev/c-periphery
- Raspberry Pi: https://www.raspberrypi.com/
- Wikipedia: https://en.wikipedia.org/wiki/Main_Page
- GPIO: https://en.wikipedia.org/wiki/General-purpose_input/output
- PWM: https://en.wikipedia.org/wiki/Pulse-width_modulation
- I2C: https://en.wikipedia.org/wiki/I%C2%B2C
- I2C Setup: https://github.com/dotnet/iot/blob/main/Documentation/raspi-i2c.md
- I2C Setup: https://github.com/fivdi/i2c-bus/blob/master/doc/raspberry-pi-i2c.md

