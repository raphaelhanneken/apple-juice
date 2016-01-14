//
// Battery.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Raphael Hanneken
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import IOKit.ps
import IOKit


/// Access information about the build in battery.
class Battery {

  /// The battery's IO service name.
  private static let batteryIOServiceName = "AppleSmartBattery"
  /// An IOService object that matches battery's IO service dict.
  private static var service: io_object_t = 0

  // MARK: Methods

  ///  Opens a connection to the battery's IO service.
  ///
  ///  - throws: * ConnectionAlreadyOpen exception, if the last connection wasn't closed properly.
  ///            * ServiceNotFound exception, if the IOSERVICE_BATTERY couldn't be found.
  static func open() throws {
    // If the IO service is still open...
    if self.service != 0 {
      // ...try closing it.
      if !self.close() {
        // Throw a BatteryError in case the IO connection won't close.
        throw BatteryError.ConnectionAlreadyOpen
      }
    }
    // Get an IOService object for the defined
    self.service = IOServiceGetMatchingService(kIOMasterPortDefault,
      IOServiceNameMatching(self.batteryIOServiceName))
    // Throw a BatteryError if the IO service couldn't be opened.
    if self.service == 0 {
      throw BatteryError.ServiceNotFound
    }
  }

  ///  Closes the connection the the battery's IO service.
  ///
  ///  - returns: True on success; false otherwise.
  static func close() -> Bool {
    // Release the IO object...
    let result = IOObjectRelease(self.service)
    // ...and reset the service property.
    if result == kIOReturnSuccess {
      self.service = 0
    }
    return (result == kIOReturnSuccess)
  }

  ///  Time until the battery is empy or fully charged, in a human readable format.
  ///
  ///  - returns: The time in a human readable format.
  static func timeRemainingFormatted() -> String {
    guard let charged = self.isCharged(), time = self.timeRemaining() else {
        return NSLocalizedString("unknown", comment: "")
    }

    if charged {
      return NSLocalizedString("charged", comment: "")
    } else {
      return String(format: "%d:%02d", arguments: [time / 60, time % 60])
    }
  }

  ///  Calculates the current percentage, based on the remaining and
  ///  maximum capacity.
  ///
  ///  - returns: The current percentage of the battery.
  static func percentage() -> String {
    guard let maxCapacity = self.maxCapacity(), currentCapacity = self.currentCapacity() else {
        return NSLocalizedString("unknown", comment: "")
    }

    return "\(Int(round(Double(currentCapacity) / Double(maxCapacity) * 100.0))) %"
  }

  ///  Calculates the current power usage based on the current voltage and amperage.
  ///
  ///  - returns: The current power usage.
  static func powerUsage() -> String {
    guard let voltage = self.getRegistryPropertyForKey(.Voltage) as? Double,
      amperage = self.getRegistryPropertyForKey(.Amperage) as? Double else {
        return NSLocalizedString("unknown", comment: "")
    }
    return "\((voltage * amperage) / 1000000) " + NSLocalizedString("watts", comment: "")
  }

  ///  Gets the current charge in mAh.
  ///
  ///  - returns: The current charge in mAh.
  static func currentCharge() -> String {
    guard let charge = self.currentCapacity(), max = self.maxCapacity() else {
      return "-- / --"
    }
    return "\(charge) / \(max) mAh"
  }

  ///  Gets the design capacity in mAh.
  ///
  ///  - returns: the design capacity in mAh.
  static func designCapacity() -> String {
    guard let capacity = self.getRegistryPropertyForKey(.DesignCapacity) as? Int else {
      return "--"
    }
    return "\(capacity)"
  }

  ///  Gets the current source of power.
  ///
  ///  - returns: The currently connected source of power.
  static func currentSource() -> String {
    guard let powered = self.isPlugged() else {
      return NSLocalizedString("unknown", comment: "")
    }

    if powered {
      return NSLocalizedString("power adapter", comment: "")
    } else {
      return NSLocalizedString("battery", comment: "")
    }
  }

  ///  Gets the current cycle count.
  ///
  ///  - returns: The current cycle count.
  static func cycleCount() -> String {
    guard let count =  self.getRegistryPropertyForKey(.CycleCount) as? Int else {
      return "--"
    }
    return "\(count)"
  }

  ///  Gets the designed cycle count.
  ///
  ///  - returns: The design cycle count.
  static func designCycleCount() -> String {
    guard let count = self.getRegistryPropertyForKey(.DesignCycleCount) as? Int else {
      return "--"
    }
    return "\(count)"
  }

  ///  Gets the current temperature of the battery, in the supplied format.
  ///
  ///  - parameter unit: Temperature unit. Default: Celsius.
  ///  - returns: The current temperature of the battery.
  static func temperature(unit: TemperatureUnit = .Celsius) -> String {
    guard let prop = self.getRegistryPropertyForKey(.Temperature) as? Double else {
      return "-- / --"
    }
    let temperature = prop / 100.0

    switch unit {
    case .Fahrenheit:
      return "\(round((temperature * 1.8) + 32)) °F"
    case .Celsius:
      return "\(round(temperature)) °C"
    }
  }

  // MARK: Private Methods

  ///  Get the registry entry's property for the supplied SmartBatteryKey.
  ///
  ///  - parameter key: A SmartBatteryKey to get the property for.
  ///  - returns: The property of the given SmartBatteryKey.
  private static func getRegistryPropertyForKey(key: SmartBatteryKey) -> AnyObject? {
    return IORegistryEntryCreateCFProperty(service, key.rawValue, kCFAllocatorDefault, 0)
      .takeRetainedValue()
  }

  ///  Gets the current capacity.
  ///
  ///  - returns: The current capacity.
  private static func currentCapacity() -> Int? {
    return self.getRegistryPropertyForKey(.CurrentCharge) as? Int
  }

  ///  Gets the maximum capacity in mAh.
  ///
  ///  - returns: The maximum capacity in mAh.
  private static func maxCapacity() -> Int? {
    return self.getRegistryPropertyForKey(.MaxCapacity) as? Int
  }

  ///  Is the battery charged?
  ///
  ///  - returns: True/false, wheter or not the battery is charged.
  private static func isCharged() -> Bool? {
    return self.getRegistryPropertyForKey(.FullyCharged) as? Bool
  }

  ///  Checks wether or not a unlimited power supply is plugged in.
  ///
  ///  - returns: true when an unlimited power supple is plugged in; false otherwise.
  private static func isPlugged() -> Bool? {
    return self.getRegistryPropertyForKey(.ACPowered) as? Bool
  }

  ///  Time until the battery is empty or fully charged.
  ///
  ///  - returns: The time in minutes.
  private static func timeRemaining() -> Int? {
    return self.getRegistryPropertyForKey(.TimeRemaining) as? Int
  }
}

// MARK: BatteryErrorType

///  Exceptions for the Battery class.
///
///  - ConnectionAlreadyOpen: Gets thrown in case the connection to the battery's IO service
///                           is already open.
///  - ServiceNotFound:       Gets thrown in case the IO service string (Battery.BatteryServiceName)
///                           wasn't found.
enum BatteryError: ErrorType {
  case ConnectionAlreadyOpen
  case ServiceNotFound
}

// MARK: SmartBatteryKey's

///  Access keys to get the battery information.
///
///  - ACPowered:        Is an external power source connected?
///  - Amperage:         How much "Juice" is currently being used (Ampere)
///  - CurrentCapacity:  Current charging status in mAh
///  - CycleCount:       How often was the current battery charged to 100%
///  - DesignCapacity:   The maximum capacity the battery could hold, by design.
///  - DesignCycleCount: How often can the current battery be charged (at least)
///  - FullyCharged:     Is the battery currently fully charged?
///  - IsCharging:       Is the battery currently charging?
///  - MaxCapacity:      The maximum capacity the battery can currently hold.
///  - Temperature:      The current temperature of the battery.
///  - TimeRemaining:    The remaining time until the battery is empty/fully charged.
///  - Voltage:          The electric charge the battery is working with.
enum SmartBatteryKey: String {
  case ACPowered        = "ExternalConnected"
  case Amperage         = "Amperage"
  case CurrentCharge    = "CurrentCapacity"
  case CycleCount       = "CycleCount"
  case DesignCapacity   = "DesignCapacity"
  case DesignCycleCount = "DesignCycleCount9C"
  case FullyCharged     = "FullyCharged"
  case IsCharging       = "IsCharging"
  case MaxCapacity      = "MaxCapacity"
  case Temperature      = "Temperature"
  case TimeRemaining    = "TimeRemaining"
  case Voltage          = "Voltage"
}

// MARK: TemperatureUnits

///  Describes temperature units.
///
///  - Celsius:    Celsius
///  - Fahrenheit: Fahrenheit
enum TemperatureUnit {
  case Celsius
  case Fahrenheit
}
