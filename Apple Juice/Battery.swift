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
public struct Battery {

  /// The battery's IO service name.
  private let batteryIOServiceName = "AppleSmartBattery"
  /// An IOService object that matches battery's IO service dict.
  private var service: io_object_t = 0

  ///  The remaining time until the battery is empty or fully charged 
  ///  in a human readable format, e.g. hh:mm.
  var timeRemainingFormatted: String {
    // Get and unwrap the necessary information.
    guard let
      time    = timeRemaining,
      charged = isCharged,
      plugged = isPlugged else {
        return NSLocalizedString("Calculating", comment: "Translate Calculating")
    }

    // If the battery is charged and plugged into a power supply display "Charged".
    // Otherwise display the remaining time.
    if charged && plugged {
      return NSLocalizedString("Charged", comment: "Translate Charged")
    } else {
      return String(format: "%d:%02d", arguments: [time / 60, time % 60])
    }
  }

  ///  The remaining time in minutes until the battery is empty or fully charged.
  var timeRemaining: Int? {
    // Get the estimated time remaining.
    let time = IOPSGetTimeRemainingEstimate()

    switch time {
    case -1.0:
      // The remaining time is currently unknown.
      return nil
    case -2.0:
      // Get the remaining time from the IO Registry, in case IOPSGetTimeRemainingEstimate
      // returned kIOPSTimeRemainingUnlimited.
      return getRegistryPropertyForKey(.timeRemaining) as? Int
    default:
      // Return the estimated time divided by 60 (seconds to minutes).
      return Int(time / 60)
    }
  }

  ///  The current percentage, based on the current charge and the maximum capacity.
  func percentage() -> Int? {
    // Get the necessary information.
    guard let
      capacity = capacity,
      charge   = charge else {
        return nil
    }
    // Calculate the current percentage.
    return Int(round(Double(charge) / Double(capacity) * 100.0))
  }

  ///  The current charge in mAh.
  var charge: Int? {
    return getRegistryPropertyForKey(.currentCharge) as? Int
  }

  ///  The maximum capacity in mAh.
  var capacity: Int? {
    return getRegistryPropertyForKey(.maxCapacity) as? Int
  }

  ///  The source from which the Mac currently draws its power.
  var powerSource: String {
    // Unwrap the necessary information or return "Unknown" in case something went wrong.
    guard let plugged = isPlugged else {
      return NSLocalizedString("Unknown", comment: "Translate Unknown")
    }
    // Check if we're currently plugged into a power adapter.
    if plugged {
      return NSLocalizedString("Power Adapter", comment: "Translate Power Adapter")
    } else {
      return NSLocalizedString("Battery", comment: "Translate Battery")
    }
  }

  ///  True when the battery is charging and connected to a power outlet.
  var isCharging: Bool? {
    return getRegistryPropertyForKey(.isCharging) as? Bool
  }

  ///  True when the battery is fully charged.
  var isCharged: Bool? {
    return getRegistryPropertyForKey(.fullyCharged) as? Bool
  }

  ///  True when the battery is connected to a power outlet.
  var isPlugged: Bool? {
    return getRegistryPropertyForKey(.externalConnected) as? Bool
  }

  ///  The current power usage in Watts.
  var powerUsage: Double? {
    guard let
      voltage  = getRegistryPropertyForKey(.voltage) as? Double,
      amperage = getRegistryPropertyForKey(.amperage) as? Double else {
        return nil
    }
    return round(((voltage * amperage) / 1000000) * 10) / 10
  }

  ///  The number of charging cycles.
  var cycleCount: Int? {
    return getRegistryPropertyForKey(.cycleCount) as? Int
  }


  // MARK: - Initializer

  ///  Initializes a new Battery object.
  init() throws {
    try openServiceConnection()
    // Get notified when the power source information changes.
    let loop = IOPSNotificationCreateRunLoopSource(powerSourceCallback, nil).takeRetainedValue()
    // Add the notification loop to the current run loop.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, CFRunLoopMode.defaultMode)
  }


  // MARK: - Private Methods

  ///  Opens a connection to the battery's IOService object.
  ///
  ///  - throws: ConnectionAlreadyOpen, if the last connection wasn't closed properly.
  ///  - throws: ServiceNotFound, if the supplied batteryIOServiceName wasn't found.
  private mutating func openServiceConnection() throws {
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

  ///  Closes the connection the the battery's IOService object.
  ///
  ///  - returns: True when the connection was successfully closed.
  private mutating func closeServiceConnection() -> Bool {
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
  ///  - returns:       The property of the given SmartBatteryKey.
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
///  - externalConnected: Is an external power source connected?
///  - amperage:          How much "Juice" is currently being used (Ampere)
///  - currentCapacity:   Current charging status in mAh
///  - cycleCount:        How often was the current battery charged to 100%
///  - designCapacity:    The maximum capacity the battery could hold, by design.
///  - designCycleCount:  How often can the current battery be charged (at least)
///  - fullyCharged:      Is the battery currently fully charged?
///  - isCharging:        Is the battery currently charging?
///  - maxCapacity:       The maximum capacity the battery can currently hold.
///  - temperature:       The current temperature of the battery.
///  - timeRemaining:     The remaining time until the battery is empty/fully charged.
///  - voltage:           The electric charge the battery is working with.
private enum SmartBatteryKey: String {
  case externalConnected = "ExternalConnected"
  case amperage          = "Amperage"
  case currentCharge     = "CurrentCapacity"
  case cycleCount        = "CycleCount"
  case designCapacity    = "DesignCapacity"
  case designCycleCount  = "DesignCycleCount9C"
  case fullyCharged      = "FullyCharged"
  case isCharging        = "IsCharging"
  case maxCapacity       = "MaxCapacity"
  case temperature       = "Temperature"
  case timeRemaining     = "TimeRemaining"
  case voltage           = "Voltage"
}
