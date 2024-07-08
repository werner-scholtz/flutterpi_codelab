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

**_NOTE:_**  If the above does not work for you can use the following method:

1. First enable [custom-devices](https://github.com/flutter/flutter/blob/master/docs/tool/Using-custom-embedders-with-the-Flutter-CLI.md#the-custom-devices-config-file).
2. Then add your pi as a custom-device [instructions](https://github.com/flutter/flutter/blob/master/docs/tool/Using-custom-embedders-with-the-Flutter-CLI.md#configuring-your-custom-device).  

...TODO: finish this.




