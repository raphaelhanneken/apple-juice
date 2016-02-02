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

  /// Returns a string that describes the contents of the receiver.
  override var description: String {
    return "\(title) \(value)"
  }

  // MARK: - Init

  override convenience init() {
    self.init(withType: .Undefined)
  }

  init(withType type: RowViewControllerTypeDef) {
    // Initialze NSObject.
    super.init()
    // Get the battery information for the supplied row type def.
    self.setProperties(forType: type)
  }

  ///  Get the appropriate battery information for the supplied RowViewType.
  ///
  ///  - parameter type: The RowViewType to get information for.
  private func setProperties(forType type: RowViewControllerTypeDef) {
    // Set the row view's title.
    setTitle(forType: type)
    do {
      // Try closing the battery connection in any case!
      defer { Battery.close() }
      // Open a new IO connection to the battery service.
      try Battery.open()
      // Set the row view's value.
      setValue(forType: type)
    } catch {
      // Print the error and set the row value to unknown.
      print(error)
      value = NSLocalizedString("unknown", comment: "")
    }
  }

  // swiftlint:disable cyclomatic_complexity

  ///  Set the row view's title.
  ///
  ///  - parameter type: The type the current row view represents.
  private func setTitle(forType type: RowViewControllerTypeDef) {
    // Check which type the current row represents.
    switch type {
    case .TimeRemaining:
      self.title = NSLocalizedString("time remaining", comment: "")
    case .CurrentCharge:
      self.title = NSLocalizedString("percentage", comment: "")
    case .PowerUsage:
      self.title = NSLocalizedString("power usage", comment: "")
    case .Capacity:
      self.title = NSLocalizedString("charge", comment: "")
    case .CycleCount:
      self.title = NSLocalizedString("cycle count", comment: "")
    case .Temperature:
      self.title = NSLocalizedString("temp", comment: "")
    case .Source:
      self.title = NSLocalizedString("power source", comment: "")
    case .DesignCycleCount:
      self.title = NSLocalizedString("design cycle count", comment: "")
    case .DesignCapacity:
      self.title = NSLocalizedString("design capacity", comment: "")
    }
  }

  ///  Set the row view's value.
  ///
  ///  - parameter type: The type the current row view represents.
  private func setValue(forType type: RowViewControllerTypeDef) {
    // Check which type the current row represents.
    switch type {
    case .TimeRemaining:
      self.value = Battery.timeRemainingFormatted()
    case .CurrentCharge:
      self.value = Battery.percentage()
    case .PowerUsage:
      self.value = Battery.powerUsage()
    case .Capacity:
      self.value = Battery.currentCharge()
    case .CycleCount:
      self.value = Battery.cycleCount()
    case .Temperature:
      self.value = Battery.temperature()
    case .Source:
      self.value = Battery.currentSource()
    case .DesignCycleCount:
      self.value = Battery.designCycleCount()
    case .DesignCapacity:
      self.value = Battery.designCapacity()
    }
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
