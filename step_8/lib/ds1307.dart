import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/material.dart';

/// Default I2C address of the DS1307.
const int ds1307DefaultI2CAddress = 0x68;

/// The year adjustment used for 2000 to 2099.
///
/// * This should be updated when the century changes.
const int defaultYearAdjustment = 2000;

class DS1307 {
  final I2C i2c;
  final int address;

  DS1307(
    this.i2c, [
    this.address = ds1307DefaultI2CAddress,
  ]);

  /// Convert a BCD value to binary.
  static int bcd2bin(int val) {
    // Convert BCD to binary by subtracting 6 times the value of the tens place
    return val - 6 * (val >> 4);
  }

  /// Convert a binary value to BCD.
  static int bin2bcd(int val) {
    // Convert binary to BCD by adding 6 times the value of the tens place
    // This function converts a binary (decimal) value to its BCD (Binary-Coded Decimal) equivalent.
    return val + 6 * (val ~/ 10);
  }

  /// Check if the RTC is running.
  bool isRunning() {
    i2c.writeByte(address, 0);

    final ss = i2c.readByte(address);

    // Isolate the MSB and negate it to determine if the RTC is running
    // If the MSB is 0, the RTC is running, so return true; otherwise, return false.
    return (ss >> 7) == 0;
  }

  /// Adjust the RTC to the given [DateTime].
  void adjust(DateTime dateTime) {
    i2c.writeBytes(
      address,
      [
        0,
        bin2bcd(dateTime.second),
        bin2bcd(dateTime.minute),
        bin2bcd(dateTime.hour),
        bin2bcd(dateTime.weekday),
        bin2bcd(dateTime.day),
        bin2bcd(dateTime.month),
        bin2bcd(dateTime.year - defaultYearAdjustment),
        0,
      ],
    );
  }

  /// Read the current date and time from the RTC.
  DateTime? read() {
    try {
      i2c.writeByte(address, 0);

      final data = i2c.readBytes(address, 7);

      return DateTime(
        2000 + bcd2bin(data[6]),
        bcd2bin(data[5]),
        bcd2bin(data[4]),
        bcd2bin(data[2]),
        bcd2bin(data[1]),
        bcd2bin(data[0]),
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
