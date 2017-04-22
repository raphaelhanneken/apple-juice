//
// SmartBatteryKeys.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//
// The MIT License (MIT)
//
// Copyright (c) 2015 - 2017 Raphael Hanneken
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
