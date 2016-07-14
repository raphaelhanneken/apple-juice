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
import IOKit.pwr_mgt

/// Notification that gets posted whenever a power source is changed.
let powerSourceChangedNotification = "com.raphaelhanneken.apple-juice.powersourcechanged"

/// Gets called whenever any power source is added, removed, or changed.
private let powerSourceCallback: IOPowerSourceCallbackType = { _ in
  // Post a PowerSourceChanged notification.
  NotificationCenter.default.post(name: Notification.Name(rawValue: powerSourceChangedNotification), object: nil)
}

/// Access information about the build in battery.
final class Battery {

  /// The battery's IO service name.
  private let batteryIOServiceName = "AppleSmartBattery"
  /// An IOService object that matches battery's IO service dict.
  private var service: io_object_t = 0

  // MARK: - Methods

  init() throws {
    try openServiceConnection()
    // Get notified when the power source information changes.
    let loop = IOPSNotificationCreateRunLoopSource(powerSourceCallback, nil).takeRetainedValue()
    // Add the notification loop to the current run loop.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, CFRunLoopMode.defaultMode)
  }

  ///  Time until the battery is empy or fully charged, in a human readable format.
  ///
  ///  - returns: The time in a human readable format.
  func timeRemainingFormatted() -> String {
    // Unwrap the necessary information or return "Unknown" in case something went wrong.
    guard let charged = isCharged(),
              plugged = isPlugged(),
              time    = timeRemaining() else {
        return NSLocalizedString("unknown", comment: "")
    }

    // If the remaining time is unlimited, just return "Charged".
    if charged && plugged {
      return NSLocalizedString("charged", comment: "")
    } else {
      return String(format: "%d:%02d", arguments: [time / 60, time % 60])
    }
  }

  ///  Time until the battery is empty or fully charged.
  ///
  ///  - returns: The time in minutes.
  func timeRemaining() -> Int? {
    return getRegistryPropertyForKey(.TimeRemaining) as? Int
  }

  ///  Calculates the current percentage, based on the current charge and
  ///  the maximum capacity.
  ///
  ///  - returns: The current percentage of the battery.
  func percentage() -> Int? {
    // Get the necessary information.
    guard let maxCapacity     = maxCapacity(),
              currentCapacity = currentCharge() else {
      return nil
    }
    // Calculate the current percentage.
    return Int(round(Double(currentCapacity) / Double(maxCapacity) * 100.0))
  }

  ///  Gets the current charge in mAh.
  ///
  ///  - returns: The current charge in mAh.
  func currentCharge() -> Int? {
    return getRegistryPropertyForKey(.CurrentCharge) as? Int
  }

  ///  Gets the maximum capacity in mAh.
  ///
  ///  - returns: The maximum capacity in mAh.
  func maxCapacity() -> Int? {
    return getRegistryPropertyForKey(.MaxCapacity) as? Int
  }

  ///  Gets the current source of power.
  ///
  ///  - returns: The currently connected source of power.
  func currentSource() -> String {
    // Unwrap the necessary information or return "Unknown" in case something went wrong.
    guard let plugged = isPlugged() else {
      return NSLocalizedString("unknown", comment: "")
    }
    // Check if we're currently plugged into a power adapter.
    if plugged {
      return NSLocalizedString("power adapter", comment: "")
    } else {
      return NSLocalizedString("battery", comment: "")
    }
  }

  ///  Is the battery currently connected to a power outlet and charging?
  ///
  ///  - returns: True or false, whether the battery is chargin or not.
  func isCharging() -> Bool? {
    return getRegistryPropertyForKey(.IsCharging) as? Bool
  }

  ///  Is the battery charged?
  ///
  ///  - returns: True/false, wheter the battery is charged or not.
  func isCharged() -> Bool? {
    return getRegistryPropertyForKey(.FullyCharged) as? Bool
  }

  ///  Checks wether or not a unlimited power supply is plugged in.
  ///
  ///  - returns: true when an unlimited power supple is plugged in; false otherwise.
  func isPlugged() -> Bool? {
    return getRegistryPropertyForKey(.ACPowered) as? Bool
  }

  ///  Calculates the current power usage based on the current voltage and amperage.
  ///
  ///  - returns: The current power usage in Watts.
  func powerUsage() -> Double? {
    guard let voltage  = getRegistryPropertyForKey(.Voltage) as? Double,
              amperage = getRegistryPropertyForKey(.Amperage) as? Double else {
        return nil
    }
    return round(((voltage * amperage) / 1000000) * 10) / 10
  }

  ///  Gets the current cycle count.
  ///
  ///  - returns: The current cycle count.
  func cycleCount() -> Int? {
    return getRegistryPropertyForKey(.CycleCount) as? Int
  }

  // MARK: - Private Methods

  ///  Opens a connection to the battery's IO service.
  ///
  ///  - throws: ConnectionAlreadyOpen exception, if the last connection wasn't closed properly.
  ///  - throws: ServiceNotFound exception, if the IOSERVICE_BATTERY couldn't be found.
  private func openServiceConnection() throws {
    // If the IO service is still open...
    if service != 0 {
      // ...try closing it.
      if !closeServiceConnection() {
        // Throw a BatteryError in case the IO connection won't close.
        throw BatteryError.connectionAlreadyOpen
      }
    }
    // Get an IOService object for the defined
    service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceNameMatching(batteryIOServiceName))
    // Throw a BatteryError if the IO service couldn't be opened.
    if service == 0 {
      throw BatteryError.serviceNotFound
    }
  }

  ///  Closes the connection the the battery's IO service.
  ///
  ///  - returns: True on success; false otherwise.
  private func closeServiceConnection() -> Bool {
    // Release the IO object...
    let result = IOObjectRelease(service)
    // ...and reset the service property.
    if result == kIOReturnSuccess {
      service = 0
    }
    return (result == kIOReturnSuccess)
  }

  ///  Get the registry entry's property for the supplied SmartBatteryKey.
  ///
  ///  - parameter key: A SmartBatteryKey to get the property for.
  ///  - returns: The property of the given SmartBatteryKey.
  private func getRegistryPropertyForKey(_ key: SmartBatteryKey) -> AnyObject? {
    return IORegistryEntryCreateCFProperty(service, key.rawValue, nil, 0).takeRetainedValue()
  }
}

// MARK: - BatteryErrorType

///  Exceptions for the Battery class.
///
///  - ConnectionAlreadyOpen: Gets thrown in case the connection to the battery's IO service
///                           is already open.
///  - ServiceNotFound:       Gets thrown in case the IO service string (Battery.BatteryServiceName)
///                           wasn't found.
enum BatteryError: ErrorProtocol {
  case connectionAlreadyOpen
  case serviceNotFound
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
private enum SmartBatteryKey: String {
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
