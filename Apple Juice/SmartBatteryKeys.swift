//
// SmartBatteryKeys.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

///  Keys to look up information from the IOService dictionary ('ioreg -brc AppleSmartBattery').
///
///  - isPlugged:     Whether the battery is connected to an external power supply.
///  - isCharging:    Whether the battery is currently charging.
///  - currentCharge: The current charging state in mAh.
///  - maxCapacity:   The maximum capacity the battery can currently hold.
///  - fullyCharged:  Whether the battery is fully charged.
///  - cycleCount:    The number of battery charging cycles.
///  - temperature:   The temperature in degrees celsius.
///  - voltage:       The current voltage.
///  - amperage:      Information about the current power consumption.
///  - timeRemaining: The remaining time until the battery is empty, or fully charged.
enum SmartBatteryKeys: String {
    case isPlugged     = "ExternalConnected"
    case isCharging    = "IsCharging"
    case currentCharge = "CurrentCapacity"
    case maxCapacity   = "MaxCapacity"
    case fullyCharged  = "FullyCharged"
    case cycleCount    = "CycleCount"
    case temperature   = "Temperature"
    case voltage       = "Voltage"
    case amperage      = "Amperage"
    case timeRemaining = "TimeRemaining"
}
