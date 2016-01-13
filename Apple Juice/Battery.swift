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

/// Notification that gets posted whenever a power source is changed.
let powerSourceChangedNotification = "io.github.raphaelhanneken.apple-juice.powersourcechanged"

/// Gets called whenever any power source is added, removed, or changed.
let powerSourceCallback: IOPowerSourceCallbackType = { _ in
  // Post a PowerSourceChanged notification.
  NSNotificationCenter.defaultCenter().postNotificationName(powerSourceChangedNotification,
    object: nil)
}

/// Access information about the build in battery.
class Battery {

  /// The battery's IO service name.
  private let batteryIOServiceName = "AppleSmartBattery"
  /// An IOService object that matches battery's IO service dict.
  private var service: io_object_t = 0

  // MARK: Methods

  init() {
    // Get notified when the power source information changes.
    let loop = IOPSNotificationCreateRunLoopSource(powerSourceCallback, nil).takeUnretainedValue()
    // Add the notification loop to the current run loop.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopDefaultMode)
  }

  ///  Opens a connection to the battery's IO service.
  ///
  ///  - throws: * ConnectionAlreadyOpen exception, if the last connection wasn't closed properly.
  ///            * ServiceNotFound exception, if the IOSERVICE_BATTERY couldn't be found.
  func open() throws {
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
  func close() -> Bool {
    // Release the IO object...
    let result = IOObjectRelease(self.service)
    // ...and reset the service property.
    if result == kIOReturnSuccess {
      self.service = 0
    }
    return (result == kIOReturnSuccess)
  }

  ///  Time until the battery is empty or fully charged.
  ///
  ///  - returns: The time in minutes.
  func timeRemaining() -> Int? {
    return self.getRegistryPropertyForKey(.TimeRemaining) as? Int
  }

  ///  Time until the battery is empy or fully charged, in a human readable format.
  ///
  ///  - returns: The time in a human readable format.
  func timeRemainingFormatted() -> String {
    guard let charged = self.isCharged(),
      time = self.timeRemaining() else {
        return "Unknown"
    }

    if charged {
      return "Charged"
    } else {
      return String(format: "%d:%02d", arguments: [time / 60, time % 60])
    }
  }

  ///  Calculates the current percentage, based on the remaining and
  ///  maximum capacity.
  ///
  ///  - returns: The current percentage of the battery.
  func percentage() -> Int? {
    guard let maxCapacity = self.maxCapacity(),
      currentCapacity = self.currentCharge() else {
        return nil
    }

    return Int(round(Double(currentCapacity) / Double(maxCapacity) * 100.0))
  }

  ///  Gets the current charge in mAh.
  ///
  ///  - returns: The current charge in mAh.
  func currentCharge() -> Int? {
    return self.getRegistryPropertyForKey(.CurrentCharge) as? Int
  }

  ///  Gets the maximum capacity in mAh.
  ///
  ///  - returns: The maximum capacity in mAh.
  func maxCapacity() -> Int? {
    return self.getRegistryPropertyForKey(.MaxCapacity) as? Int
  }

  ///  Gets the design capacity in mAh.
  ///
  ///  - returns: the design capacity in mAh.
  func designCapacity() -> Int? {
    return self.getRegistryPropertyForKey(.DesignCapacity) as? Int
  }

  ///  Gets the current source of power.
  ///
  ///  - returns: The currently connected source of power.
  func currentSource() -> String {
    guard let powered = self.isPlugged() else {
      return "Unknown"
    }

    if powered {
      return "Power Adapter"
    } else {
      return "Battery"
    }
  }

  ///  Checks wether or not the battery is currently charging.
  ///
  ///  - returns: true when the battery currently gets charged; false otherwise.
  func isCharging() -> Bool? {
    return self.getRegistryPropertyForKey(.IsCharging) as? Bool
  }

  ///  Is the battery charged?
  ///
  ///  - returns: True/false, wheter or not the battery is charged.
  func isCharged() -> Bool? {
    return self.getRegistryPropertyForKey(.FullyCharged) as? Bool
  }

  ///  Checks wether or not a unlimited power supply is plugged in.
  ///
  ///  - returns: true when an unlimited power supple is plugged in; false otherwise.
  func isPlugged() -> Bool? {
    return self.getRegistryPropertyForKey(.ACPowered) as? Bool
  }

  ///  Gets the current cycle count.
  ///
  ///  - returns: The current cycle count.
  func cycleCount() -> Int? {
    return self.getRegistryPropertyForKey(.CycleCount) as? Int
  }

  ///  Gets the designed cycle count.
  ///
  ///  - returns: The design cycle count.
  func designCycleCount() -> Int? {
    return self.getRegistryPropertyForKey(.DesignCycleCount) as? Int
  }

  // MARK: Private Methods

  ///  Get the registry entry's property for the supplied SmartBatteryKey.
  ///
  ///  - parameter key: A SmartBatteryKey to get the property for.
  ///  - returns: The property of the given SmartBatteryKey.
  private func getRegistryPropertyForKey(key: SmartBatteryKey) -> AnyObject? {
    return IORegistryEntryCreateCFProperty(service, key.rawValue, kCFAllocatorDefault, 0)
      .takeRetainedValue()
  }

  ///  Gets the current temperature of the battery, in the supplied format.
  ///
  ///  - parameter unit: Temperature unit. Default: Celsius.
  ///  - returns: The current temperature of the battery.
  func temperature(unit: TemperatureUnit = .Celsius) -> Double? {
    guard let prop = self.getRegistryPropertyForKey(.Temperature) as? Double else {
      return nil
    }
    let temperature = prop / 100.0

    switch unit {
    case .Fahrenheit:
      return round((temperature * 1.8) + 32)
    case .Celsius:
      return round(temperature)
    }
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
