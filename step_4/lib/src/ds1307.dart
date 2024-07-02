import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/material.dart';

/// Default I2C address of the DS1307.
const int defaultDS1307I2CAddress = 0x68;

/// The year adjustment used for 2000 to 2099.
///
/// * This should be updated when the century changes.
const int defaultYearAdjustment = 2000;

class DS1307 {
  final I2C i2c;
  final int address;
  final int yearAdjustment;

  DS1307(
    this.i2c, [
    this.address = defaultDS1307I2CAddress,
    this.yearAdjustment = defaultYearAdjustment,
  ]);

  /// Convert a binary-coded decimal(BCD) value to binary integer.
  static int bcd2bin(int val) {
    // Convert BCD to binary by subtracting 6 times the value of the tens place
    return val - 6 * (val >> 4);
  }

  /// Convert a binary integer to binary-coded decimal (BCD).
  ///
  ///  This function converts a binary (decimal) value to its BCD (Binary-Coded Decimal) equivalent.
  static int bin2bcd(int val) {
    // Convert binary to BCD by adding 6 times the value of the tens place.
    return val + 6 * (val ~/ 10);
  }

  /// Check if the RTC is running.
  bool isRunning() {
    i2c.writeByte(address, 0);

    final seconds = i2c.readByte(address);

    // Isolate the most significant bit (MSB) and negate it to determine if the RTC is running
    // If the MSB is 0, the RTC is running, so return true; otherwise, return false.
    return (seconds >> 7) == 0;
  }

  /// Adjust the RTC to the given [DateTime].
  void adjust(DateTime dateTime) {
    final seconds = bin2bcd(dateTime.second);
    final minutes = bin2bcd(dateTime.minute);
    final hours = bin2bcd(dateTime.hour);
    final weekday = bin2bcd(dateTime.weekday);
    final day = bin2bcd(dateTime.day);
    final month = bin2bcd(dateTime.month);
    final year = bin2bcd(dateTime.year - yearAdjustment);

    i2c.writeBytes(
      address,
      [0, seconds, minutes, hours, weekday, day, month, year, 0],
    );
  }

  /// Read the current date and time from the RTC.
  DateTime? read() {
    try {
      i2c.writeByte(address, 0);

      final data = i2c.readBytes(address, 7);
      final seconds = bcd2bin(data[0]);
      final minutes = bcd2bin(data[1]);
      final hours = bcd2bin(data[2]);
      final day = bcd2bin(data[4]);
      final month = bcd2bin(data[5]);
      final year = bcd2bin(data[6]) + yearAdjustment;

      return DateTime(year, month, day, hours, minutes, seconds, 0, 0);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
