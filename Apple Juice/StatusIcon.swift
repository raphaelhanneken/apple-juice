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

///  Define the BatteryUIKit path
private let batteryIconPath = "/System/Library/PrivateFrameworks/BatteryUIKit.framework/Versions/A/Resources/"

///  Draws the status bar image.
final class StatusIcon {
  ///  Add a little offset to draw the capacity bar in the correct position.
  private let capacityOffsetX: CGFloat = 2.0
  ///  Caches the last drawn battery image.
  private var cache: BatteryImageCache?


  // MARK: - Methods

  ///  Draws a battery image for the supplied BatteryStatusType.
  ///
  ///  - parameter status: The BatteryStatusType, which to draw the image for.
  ///  - returns:          The battery image for the provided battery status.
  func drawBatteryImage(forStatus status: BatteryStatusType) -> NSImage? {
    // Check if the required image is cached.
    if let cache = self.cache where cache.batteryStatus == status {
      return cache.image
    }

    // Cache a new battery image.
    switch status {
    case .charging:
      self.cache = BatteryImageCache(forStatus: status,
                                     withImage: batteryImage(named: .charging))
    case .pluggedAndCharged:
      self.cache = BatteryImageCache(forStatus: status,
                                     withImage: batteryImage(named: .charged))
    case .discharging(let percentage):
      self.cache = BatteryImageCache(forStatus: status,
                                     withImage: dischargingBatteryImage(forPercentage: percentage))
    }
    // Return the new image.
    return cache?.image
  }

  ///  Draws a battery image according to the provided BatteryError.
  ///
  ///  - parameter err: The BatteryError, which to draw the battery image for.
  ///  - returns:       The battery image for the supplied BatteryError.
  func drawBatteryImage(forError err: BatteryError?) -> NSImage? {
    guard let error = err else {
      return nil
    }
    // Get the corresponding image for the supplied error.
    switch error {
    case .connectionAlreadyOpen:
      return batteryImage(named: .dead)
    case .serviceNotFound:
      return batteryImage(named: .none)
    }
  }


  // MARK: - Private

  ///  Draws a battery icon based on the battery's current percentage.
  ///
  ///  - parameter percentage: The current percentage of the battery.
  ///  - returns:              A battery image for the supplied percentage.
  private func dischargingBatteryImage(forPercentage percentage: Int) -> NSImage? {
    // Get the required images to draw the battery icon.
    guard let batteryEmpty     = batteryImage(named: .empty),
              capacityCapLeft  = batteryImage(named: .left),
              capacityCapRight = batteryImage(named: .right),
              capacityFill     = batteryImage(named: .middle) else {
        return nil
    }
    // Get the capacity bar's height.
    let capacityHeight = capacityFill.size.height
    // Calculate the offset to achieve that little gap between the capacity bar and the outline.
    let capacityOffsetY = batteryEmpty.size.height - (capacityHeight + capacityOffsetX)
    // Calculate the capacity bar's width.
    let capacityWidth = CGFloat(round(Double(percentage) / 12.5)) * capacityFill.size.width
    // Define the drawing rect in which to draw the capacity bar in.
    let drawingRect = NSRect(x: capacityOffsetX, y: capacityOffsetY,
                             width: capacityWidth, height: capacityHeight)
    // Draw a special battery icon for low percentages, otherwise
    // drawThreePartImage glitches.
    if drawingRect.width < (2 * capacityFill.size.width) {
      print("Low Battery image for \(percentage)%")
      return NSImage(named: "LowBattery")
    }

    // Draw the actual menu bar image.
    drawThreePartImage(withFrame: drawingRect, canvas: batteryEmpty, startCap: capacityCapLeft,
                       fill: capacityFill, endCap: capacityCapRight)

    return batteryEmpty
  }

  ///  Opens an image file for the supplied image name.
  ///
  ///  - parameter name: The name of the requested image.
  ///  - returns:        The requested image.
  private func batteryImage(named name: BatteryImage) -> NSImage? {
    // Get the battery image for the supplied BatteryImage name.
    return NSImage(contentsOfFile: batteryIconPath + name.rawValue)
  }

  ///  Draws a three-part image onto a specified canvas image.
  ///
  ///  - parameter rect:  The rectangle in which to draw the images.
  ///  - parameter img:   The image on which to draw the three-part image.
  ///  - parameter start: The image located on the left end of the frame.
  ///  - parameter fill:  The image used to fill the gap between the start and the end images.
  ///  - parameter end:   The image located on the right end of the frame.
  private func drawThreePartImage(withFrame rect: NSRect, canvas img: NSImage,
                                  startCap start: NSImage, fill: NSImage, endCap end: NSImage) {
    img.lockFocus()
    NSDrawThreePartImage(rect, start, fill, end, false, .copy, 1, false)
    img.unlockFocus()
  }
}


// MARK: - Support

///  Defines the filenames for Apple's battery images.
///
///  - left:     Left-hand side capacity bar cap.
///  - right:    Right-hand side capacity bar cap.
///  - middle:   Capacity bar filler filename.
///  - empty:    Empty battery filename.
///  - charged:  Charged and plugged battery filename.
///  - charging: Charging battery filename.
///  - dead:     IOService already open filename.
///  - none:     Battery IOService not found filename.
private enum BatteryImage: String {
  case left     = "BatteryLevelCapB-L.pdf"
  case right    = "BatteryLevelCapB-R.pdf"
  case middle   = "BatteryLevelCapB-M.pdf"
  case empty    = "BatteryEmpty.pdf"
  case charged  = "BatteryChargedAndPlugged.pdf"
  case charging = "BatteryCharging.pdf"
  case dead     = "BatteryDeadCropped.pdf"
  case none     = "BatteryNone.pdf"
}
