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


///  Notification name for the power source changed callback.
let powerSourceChangedNotification = "com.raphaelhanneken.apple-juice.powersourcechanged"

///  Posts a notification every time the power source changes.
private let powerSourceCallback: IOPowerSourceCallbackType = { _ in
  NotificationCenter.default.post(name: Notification.Name(rawValue: powerSourceChangedNotification), object: nil)
}

///  Accesses the battery's IO service.
struct Battery {

  ///  The battery's IO service name.
  private let batteryIOServiceName = "AppleSmartBattery"

  ///  An IOService object that matches battery's IO service dictionary.
  private var service: io_object_t = 0

  ///  The remaining time until the battery is empty or fully charged
  ///  in a human readable format, e.g. hh:mm.
  var timeRemainingFormatted: String {
    // Unwrap required information.
    guard let
      time    = timeRemaining,
      charged = isCharged,
      plugged = isPlugged else {
        return NSLocalizedString("Calculating", comment: "Translate Calculating")
    }

    // If the battery is charged and plugged into an unlimited power supply return "Charged".
    // Otherwise display the remaining time.
    if charged && plugged {
      return NSLocalizedString("Charged", comment: "Translate Charged")
    } else {
      return String(format: "%d:%02d", arguments: [time / 60, time % 60])
    }
  }

  ///  The remaining time in _minutes_ until the battery is empty or fully charged.
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
  var percentage: Int? {
    // Unwrap the required information.
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
    guard let plugged = isPlugged else {
      return NSLocalizedString("Unknown", comment: "Translate Unknown")
    }
    // Check whether the MacBook currently is plugged into a power adapter.
    if plugged {
      return NSLocalizedString("Power Adapter", comment: "Translate Power Adapter")
    } else {
      return NSLocalizedString("Battery", comment: "Translate Battery")
    }
  }

  ///  Checks whether the battery is charging and connected to a power outlet.
  var isCharging: Bool? {
    return getRegistryPropertyForKey(.isCharging) as? Bool
  }

  ///  Checks whether the battery is fully charged.
  var isCharged: Bool? {
    return getRegistryPropertyForKey(.fullyCharged) as? Bool
  }

  ///  Checks whether the battery is plugged into an unlimited power supply.
  var isPlugged: Bool? {
    return getRegistryPropertyForKey(.externalConnected) as? Bool
  }

  ///  Calculates the current power usage in Watts.
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

  ///  The current status of the battery, e.g. charging.
  var status: BatteryStatusType? {
    guard let
      charging   = isCharging,
      plugged    = isPlugged,
      charged    = isCharged,
      percentage = percentage else {
        return nil
    }
    if charged && plugged {
      return .pluggedAndCharged
    }
    if charging {
      return .charging
    } else {
      return .discharging(percentage: percentage)
    }
  }


  // MARK: - Initializer

  ///  Initializes a new Battery object.
  init() throws {
    // Try opening a connection to the battery's IOService.
    try openServiceConnection()
    // Create a RunLoopSource to post a notification, whenever the power source chages.
    let loop = IOPSNotificationCreateRunLoopSource(powerSourceCallback, nil).takeRetainedValue()
    // Add the notification loop to the current run loop.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, CFRunLoopMode.defaultMode)
  }


  // MARK: - Private Methods

  ///  Opens a connection to the battery's IOService object.
  ///
  ///  - throws: A BatteryError if something went wrong.
  private mutating func openServiceConnection() throws {
    // Check if the IOService connection is still open.
    if service != 0 {
      if !closeServiceConnection() {
        // Throw a connectionAlreadyOpen Exception if the
        // IOService connection won't close.
        throw BatteryError.connectionAlreadyOpen("Closing the IOService connection failed.")
      }
    }
    // Get an IOService object for the defined battery service name.
    service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceNameMatching(batteryIOServiceName))
    if service == 0 {
      // Throw a serviceNotFound exception if the supplied IOService couldn't be opened.
      throw BatteryError.serviceNotFound("Opening the provided IOService (\(batteryIOServiceName)) failed.")
    }
  }

  ///  Closes the connection the the battery's IOService object.
  ///
  ///  - returns: True, whether the IOService connection was successfully closed.
  private mutating func closeServiceConnection() -> Bool {
    // Release the IOService object and reset the service property.
    if kIOReturnSuccess == IOObjectRelease(service) {
      service = 0
    }
    return (service == 0)
  }

  ///  Get the registry entry's property for the supplied SmartBatteryKey.
  ///
  ///  - parameter key: A SmartBatteryKey to get the corresponding registry entry's property.
  ///  - returns:       The registry entry for the provided SmartBatteryKey.
  private func getRegistryPropertyForKey(_ key: SmartBatteryKey) -> AnyObject? {
    return IORegistryEntryCreateCFProperty(service, key.rawValue, nil, 0).takeRetainedValue()
  }
}


// MARK: - Support

///  Exceptions for the Battery class.
///
///  - ConnectionAlreadyOpen: Get's thrown in case the connection to the battery's IOService
///                           is already open. Accepts an error description of type String.
///  - ServiceNotFound:       Get's thrown in case the supplied IOService wasn't found.
///                           Accepts an error description of type String.
enum BatteryError: ErrorProtocol {
  case connectionAlreadyOpen(String)
  case serviceNotFound(String)
}


///  Keys to look up required information from the IOService dictionary.
///
///  - externalConnected: Checks whether the battery is connected to an external power supply.
///  - amperage:          Information about the current power consumption.
///  - currentCapacity:   The current charging state in mAh.
///  - cycleCount:        The number of battery charging cycles.
///  - designCapacity:    The maximum capacity the battery can hold by design.
///  - designCycleCount:  Number of charg cycles according to the manufacturer.
///  - fullyCharged:      Information about whether the battery is fully charged.
///  - isCharging:        Information about whether the battery is currently charging.
///  - maxCapacity:       The maximum capacity the battery can currently hold.
///  - temperature:       The temperature in degrees celsius.
///  - timeRemaining:     The remaining time until the battery is empty or fully charged, respectively.
///  - voltage:           The current voltage.
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

///  Defines the status the battery is currently in.
///
///  - pluggedAndCharged: The battery is currently plugged into a power supply and charged.
///  - charging:          The battery is currently plugged into a power supply and charging.
///  - discharging:       The battery is currently discharging. Accepts an associated integer value.
enum BatteryStatusType: Equatable {
  case pluggedAndCharged
  case charging
  case discharging(percentage: Int)
}

//   MARK: BatteryStatusType Equatable
///  Compares two BatteryStatusTypes and return true when they are equal
///  and false otherwise.
func == (lhs: BatteryStatusType, rhs: BatteryStatusType) -> Bool {
  switch (lhs, rhs) {
  case (.charging, .charging), (.pluggedAndCharged, .pluggedAndCharged):
    return true
  case (.discharging(let lhsPercentage), .discharging(let rhsPercentage)):
    return (lhsPercentage == rhsPercentage)
  default:
    return false
  }
}
