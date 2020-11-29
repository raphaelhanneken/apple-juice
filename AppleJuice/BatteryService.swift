//
// Battery.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation
import IOKit.ps

/// Notification name for the power source changed callback.
let powerSourceChangedNotification = "com.raphaelhanneken.apple-juice.powersourcechanged"

/// Posts a notification every time the power source changes.
private let powerSourceCallback: IOPowerSourceCallbackType = { _ in
    NotificationCenter.default.post(name: Notification.Name(rawValue: powerSourceChangedNotification),
                                    object: nil)
}

/// Accesses the battery's IO service.
final class BatteryService {
    // MARK: Lifecycle

    /// Initializes a new Battery object.
    init() throws {
        try openServiceConnection()
        CFRunLoopAddSource(CFRunLoopGetCurrent(),
                           IOPSNotificationCreateRunLoopSource(powerSourceCallback, nil).takeRetainedValue(),
                           CFRunLoopMode.defaultMode)
    }

    // MARK: Internal

    /// The current status of the battery, e.g. charging.
    var state: BatteryState? {
        guard let charging = isCharging,
              let plugged = isPlugged,
              let charged = isCharged
        else {
            return nil
        }
        if charged, plugged {
            return .chargedAndPlugged
        }
        if charging {
            return .charging(percentage: percentage)
        }

        return .discharging(percentage: percentage)
    }

    /// The estimated time remaining until the battery is empty or fully charged.
    var timeRemaining: TimeRemaining {
        let time = IOPSGetTimeRemainingEstimate()
        switch time {
        case kIOPSTimeRemainingUnknown:
            return TimeRemaining(minutes: nil, state: state)
        case kIOPSTimeRemainingUnlimited:
            // The battery is connected to a power outlet, get the remaining time
            // until the battery is fully charged.
            return TimeRemaining(minutes: getRegistryProperty(forKey: .timeRemaining) as? Int, state: state)
        default:
            return TimeRemaining(minutes: Int(time / 60), state: state)
        }
    }

    /// The current percentage, based on the current charge and the maximum capacity.
    var percentage: Percentage {
        Percentage(numeric: getPowerSourceProperty(forKey: .percentage) as? Int)
    }

    /// The current charge in mAh.
    var charge: Int? {
        getRegistryProperty(forKey: .currentCharge) as? Int
    }

    /// The maximum capacity in mAh.
    var capacity: Int? {
        getRegistryProperty(forKey: .maxCapacity) as? Int
    }

    /// The source from which the Mac currently draws its power.
    var powerSource: String {
        guard let plugged = isPlugged else {
            return NSLocalizedString("Unknown", comment: "")
        }

        if plugged {
            return NSLocalizedString("Power Adapter", comment: "")
        }

        return NSLocalizedString("Battery", comment: "")
    }

    /// Checks whether the battery is charging and connected to a power outlet.
    var isCharging: Bool? {
        getRegistryProperty(forKey: .isCharging) as? Bool
    }

    /// Checks whether the battery is fully charged.
    var isCharged: Bool? {
        getRegistryProperty(forKey: .fullyCharged) as? Bool
    }

    /// Checks whether the battery is plugged into an unlimited power supply.
    var isPlugged: Bool? {
        getRegistryProperty(forKey: .isPlugged) as? Bool
    }

    /// Calculates the current power usage in Watts.
    var powerUsage: Double? {
        guard let voltage = getRegistryProperty(forKey: .voltage) as? Double,
              let amperage = getRegistryProperty(forKey: .amperage) as? Double
        else {
            return nil
        }
        return round((voltage * amperage) / 1_000_000)
    }

    /// Current flowing into or out of the battery.
    var amperage: Int? {
        return getRegistryProperty(forKey: .amperage) as? Int
    }

    /// The number of charging cycles.
    var cycleCount: Int? {
        getRegistryProperty(forKey: .cycleCount) as? Int
    }

    /// The battery's current temperature.
    var temperature: Double? {
        guard let temp = getRegistryProperty(forKey: .temperature) as? Double else {
            return nil
        }
        return (temp / 100)
    }

    /// The batteries' health status
    var health: String? {
        getPowerSourceProperty(forKey: .health) as? String
    }

    // MARK: Private

    /// Closed state value for the service connection object.
    private static let connectionClosed: UInt32 = 0

    /// An IOService object that matches battery's IO service dictionary.
    private var service: io_object_t = BatteryService.connectionClosed

    /// Opens a connection to the battery's IOService object.
    ///
    /// - throws: A BatteryError if something went wrong.
    private func openServiceConnection() throws {
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                              IOServiceNameMatching(RegistryKey.service.rawValue))

        if service == BatteryService.connectionClosed {
            throw BatteryError
                .serviceNotFound("Opening the provided IOService (\(RegistryKey.service.rawValue)) failed.")
        }
    }

    /// Closes the connection the the battery's IOService object.
    ///
    /// - returns: True, when the IOService connection was successfully closed.
    private func closeServiceConnection() -> Bool {
        if kIOReturnSuccess == IOObjectRelease(service) {
            service = BatteryService.connectionClosed
        }

        return (service == BatteryService.connectionClosed)
    }

    /// Get the registry entry's property for the supplied SmartBatteryKey.
    ///
    /// - parameter key: A SmartBatteryKey to get the corresponding registry entry's property.
    /// - returns: The registry entry for the provided SmartBatteryKey.
    private func getRegistryProperty(forKey key: RegistryKey) -> AnyObject? {
        IORegistryEntryCreateCFProperty(service, key.rawValue as CFString?, nil, 0)
            .takeRetainedValue()
    }

    private func getPowerSourceProperty(forKey key: RegistryKey) -> Any? {
        let psInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let psList = IOPSCopyPowerSourcesList(psInfo).takeRetainedValue() as? [CFDictionary]

        guard let powerSources = psList else {
            return nil
        }
        let powerSource = powerSources[0] as NSDictionary

        return powerSource[key.rawValue]
    }
}
