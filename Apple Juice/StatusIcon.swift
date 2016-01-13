//
// StatusIcon.swift
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

import Cocoa

class StatusIcon {
  /// A little offset to draw the capacity bar in the correct position.
  private static let capacityBarOffset: CGFloat = 2.0

  /// Returns the charged and plugged battery image.
  static var batteryChargedAndPlugged: NSImage? {
    return StatusIcon.batteryImage(named: "BatteryChargedAndPlugged")
  }

  /// Returns the charging battery image.
  static var batteryCharging: NSImage? {
    return StatusIcon.batteryImage(named: "BatteryCharging")
  }

  ///  Draws a battery icon based on the current percentage charge of the battery.
  ///
  ///  - parameter percentage: The current percentage charge of the battery.
  ///  - returns: The battery icon based on the given parameters.
  static func batteryDischarging(currentPercentage percentage: Int) -> NSImage? {
    // Get the images to draw the battery icon.
    guard let batteryOutline = StatusIcon.batteryImage(named: "BatteryEmpty"),
      batteryLeft  = StatusIcon.batteryImage(named: "BatteryLevelCapB-L"),
      batteryRight = StatusIcon.batteryImage(named: "BatteryLevelCapB-R"),
      batteryMid   = StatusIcon.batteryImage(named: "BatteryLevelCapB-M") else {
        return nil
    }

    let capacityBarHeight    = batteryLeft.size.height
    let capacityBarOffsetTop = batteryOutline.size.height - capacityBarOffset - capacityBarHeight
    var capacityBarLength    = CGFloat(Double(percentage) / 13) * batteryMid.size.width

    if batteryMid.size.width >= capacityBarLength {
      capacityBarLength = (2 * batteryMid.size.width) + 0.1
    }
    let drawingRect = NSRect(x: capacityBarOffset, y: capacityBarOffsetTop,
      width: capacityBarLength, height: capacityBarHeight)

    batteryOutline.lockFocus()
    NSDrawThreePartImage(drawingRect, batteryLeft, batteryMid, batteryRight, false,
      .CompositeCopy, 1, false)
    batteryOutline.unlockFocus()

    return batteryOutline
  }

  ///  Retrieves the battery image for the supplied image name.
  ///
  ///  - parameter name: Name of the image.
  ///  - returns: The image.
  private static func batteryImage(named name: String) -> NSImage? {
    // Define the path to apple's battery icons.
    let path = "/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/"

    // Open the supplied file as NSImage.
    if let img = NSImage(contentsOfFile: "\(path)\(name).pdf") {
      return img
    } else {
      print("An error occured while reading image named: \(name)")
      return nil
    }
  }
}
