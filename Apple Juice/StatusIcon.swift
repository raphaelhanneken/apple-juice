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

/// Methods to draw the status bat item's icon.
final class StatusIcon {
  /// A little offset to draw the capacity bar in the correct position.
  private static let capacityOffsetX: CGFloat = 2.0

  /// Returns the charged and plugged battery image.
  static var batteryChargedAndPlugged: NSImage? {
    return StatusIcon.batteryImage(named: .charged)
  }

  /// Returns the charging battery image.
  static var batteryCharging: NSImage? {
    return StatusIcon.batteryImage(named: .charging)
  }

  /// Returns the battery image for a ConnectionAlreadyOpen error.
  static var batteryConnectionAlreadyOpen: NSImage? {
    return StatusIcon.batteryImage(named: .dead)
  }

  /// Returns the battery image for a ServiceNotFound error.
  static var batteryServiceNotFound: NSImage? {
    return StatusIcon.batteryImage(named: .none)
  }

  ///  Draws a battery icon based on the current percentage charge of the battery.
  ///
  ///  - parameter percentage: The current percentage charge of the battery.
  ///  - returns: The battery icon based on the given parameters.
  static func batteryDischarging(currentPercentage percentage: Int) -> NSImage? {
    // Get the required images to draw the battery icon.
    guard let batteryEmpty     = StatusIcon.batteryImage(named: .empty),
              capacityCapLeft  = StatusIcon.batteryImage(named: .left),
              capacityCapRight = StatusIcon.batteryImage(named: .right),
              capacityFill     = StatusIcon.batteryImage(named: .middle) else {
        return nil
    }
    // Get the height of the capacity bar.
    let capacityHeight = capacityFill.size.height
    // Calculate the offset to achieve this little gap between the capacity bar and the outline.
    let capacityOffsetY = batteryEmpty.size.height - (capacityHeight + capacityOffsetX)
    // Calculate the width of the capacity bar.
    var capacityWidth = CGFloat(ceil(Double(percentage / 12))) * capacityFill.size.width
    // Don't draw the capacity bar smaller than two single battery images, to prevent
    // graphic errors.
    if (2 * capacityFill.size.width) >= capacityWidth {
      capacityWidth = (2 * capacityFill.size.width) + 0.1
    }
    // Define the drawing rect.
    let drawingRect = NSRect(x: capacityOffsetX, y: capacityOffsetY,
                             width: capacityWidth, height: capacityHeight)

    // Finally, draw the actual menu bar icon.
    drawThreePartImage(frame: drawingRect, canvas: batteryEmpty, startCap: capacityCapLeft,
                       fill: capacityFill, endCap: capacityCapRight)

    return batteryEmpty
  }

  ///  Retrieves the battery image for the supplied image name.
  ///
  ///  - parameter name: Name of the image.
  ///  - returns: The image.
  private static func batteryImage(named name: BatteryImage) -> NSImage? {
    // Define the path to apple's battery icons.
    let path = "/System/Library/PrivateFrameworks/BatteryUIKit.framework/Versions/A/Resources/"
    // Open the supplied file as NSImage.
    if let img = NSImage(contentsOfFile: "\(path)\(name.rawValue).pdf") {
      return img
    } else {
      print("An error occured while reading image named: \(name)")
    }

    return nil
  }

  ///  Draws a three part tiled image.
  ///
  ///  - parameter rect:  The rectangle in which to draw the image.
  ///  - parameter img:   The NSImage object to draw on.
  ///  - parameter start: The left edge of the image frame.
  ///  - parameter fill:  The image used to fill the space between the start and endCap images.
  ///  - parameter end:   The right edge of the image frame.
  private static func drawThreePartImage(frame rect: NSRect, canvas img: NSImage,
                                         startCap start: NSImage, fill: NSImage, endCap end: NSImage) {
    img.lockFocus()
    NSDrawThreePartImage(rect, start, fill, end, false, .copy, 1, false)
    img.unlockFocus()
  }
}


///  Holds the image names for all battery images.
///
///  - left:     Image name for the battery level cap on the left hand side.
///  - right:    Image name for the battery level cap on the right hand side.
///  - middle:   The name for the battery level filler image. Between the left and the right cap.
///  - empty:    Image name for the empty battery image.
///  - charged:  Image name for the charged battery image.
///  - charging: Image name for the charging battery image.
///  - dead:     Image name for the dead/cropped battery image.
///  - none:     Image name for the "Not found" battery image.
enum BatteryImage: String {
  case left     = "BatteryLevelCapB-L"
  case right    = "BatteryLevelCapB-R"
  case middle   = "BatteryLevelCapB-M"
  case empty    = "BatteryEmpty"
  case charged  = "BatteryChargedAndPlugged"
  case charging = "BatteryCharging"
  case dead     = "BatteryDeadCropped"
  case none     = "BatteryNone"
}
