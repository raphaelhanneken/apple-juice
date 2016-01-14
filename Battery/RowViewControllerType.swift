//
// RowViewControllerType.swift
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

/// Defines the type for the RowViewController
class RowViewControllerType: NSObject {

  /// Holds the row view title, e.g. "Cycle Count"
  var title: String = ""
  /// Holds the row view value, e.g. 385
  var value: String = ""

  init(withType type: RowViewControllerTypeDef) {
    // Initialize the parent.
    super.init()
    // Get the battery information for the supplied row type def.
    self.getInformation(forType: type)
  }

  ///  Get the appropriate battery information for the supplied RowViewType.
  ///
  ///  - parameter type: The RowViewType to get information for.
  private func getInformation(forType type: RowViewControllerTypeDef) {
    do {
      // Try closing the battery connection in any case!
      defer { Battery.close() }
      // Open a new IO connection to the battery service.
      try Battery.open()
      // Shadow the row properties.
      let title: String
      let value: String
      // Check which typ the row represents.
      switch type {
      case .TimeRemaining:
        title = "Time Remaining:"
        value = Battery.timeRemainingFormatted()
      case .CurrentCharge:
        title = "Percentage:"
        value = Battery.percentage()
      case .PowerUsage:
        title = "Power Usage:"
        value = Battery.powerUsage()
      case .Capacity:
        title = "Charge:"
        value = Battery.currentCharge()
      case .CycleCount:
        title = "Cycle Count:"
        value = Battery.cycleCount()
      case .Temperature:
        title = "Temperature:"
        value = Battery.temperature()
      case .Source:
        title = "Power Source:"
        value = Battery.currentSource()
      case .DesignCycleCount:
        title = "Design Cycle Count:"
        value = Battery.designCycleCount()
      case .DesignCapacity:
        title = "Design Capacity:"
        value = Battery.designCapacity()
      }
      // Write the title and value to the properies.
      self.title = title
      self.value = value
    } catch {
      print(error)
    }
  }

  override var description: String {
    return "\(self.title) \(self.value)"
  }
}

///  Represents a RowViewControllerType with information about a certain
///  battery status.
///
///  - TimeRemaining:    The time remaining until full.
///  - CurrentCharge:    The current charge in percent.
///  - PowerUsage:       The current power usage in Watts.
///  - Capacity:         The current charge and max capacity in mAh.
///  - CycleCount:       The battery's cycle count.
///  - Temperature:      The current temperature in C/F.
///  - Source:           The current power source.
///  - DesignCycleCount: The design cycle count.
///  - DesignCapacity:   The design capacity in mAh.
enum RowViewControllerTypeDef {
  case TimeRemaining
  case CurrentCharge
  case PowerUsage
  case Capacity
  case CycleCount
  case Temperature
  case Source
  case DesignCycleCount
  case DesignCapacity
}
