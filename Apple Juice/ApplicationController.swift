//
// ApplicationDelegate.swift
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

class ApplicationController: NSObject {
  /// Holds a reference to the application menu.
  @IBOutlet weak var appMenu: NSMenu!
  /// Holds a reference to the charging status menu item.
  @IBOutlet weak var currentCharge: NSMenuItem!
  /// Holds a reference to the power source menu item.
  @IBOutlet weak var currentSource: NSMenuItem!

  /// Holds the app's status bar item.
  var statusItem: NSStatusItem?
  /// Access to battery information.
  let battery = Battery()

  // MARK: Methods

  override init() {
    // Initialize our parent class.
    super.init()
    // Configure the status bar item.
    self.statusItem = self.configureStatusItem()
    // Listen for PowerSourceChanged notifications, posted by self.battery. And call
    // updateStatusItem: to reflect the changes on the status bar item.
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateStatusItem:"),
      name: PowerSourceChanged, object: self.battery)
    // Display the status bar item.
    self.updateStatusItem(self)
  }

  ///  Creates and configures the app's status bar item.
  ///
  ///  - returns: The application's status bar item.
  func configureStatusItem() -> NSStatusItem {
    // Find a place to life.
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    // Set properties.
    statusItem.target = self
    statusItem.action = Selector("displayAppMenu:")

    return statusItem
  }

  ///  Displays the app menu on screen.
  ///
  ///  - parameter sender: The object that send the message.
  func displayAppMenu(sender: AnyObject) {
    if let statusItem = self.statusItem {
      statusItem.popUpStatusItemMenu(self.appMenu)
    }
  }

  ///  Updates the application's status bar item.
  ///
  ///  - parameter sender: Object that send the message.
  func updateStatusItem(sender: AnyObject) {
    // Unwrap the status item's button.
    guard let button = self.statusItem?.button else {
      return
    }

    do {
      // Try closing the IO connection in any case.
      defer { self.battery.close() }
      // Open an IO connection to the defined battery service.
      try self.battery.open()
      // Unwrap the necessary information...
      if let plugged = self.battery.isPlugged(), charging = self.battery.isCharging(),
        charged = self.battery.isCharged(), percentage = self.battery.percentage() {
          // ...and draw the appropriate status bar icon.
          if charged && plugged {
            button.image = StatusIcon.batteryChargedAndPlugged
          } else if charging {
            button.image = StatusIcon.batteryCharging
          } else {
            button.image = StatusIcon.batteryDischarging(currentPercentage: percentage)
          }
          // Draw the status icon on the right hand side.
          button.imagePosition = .ImageRight
          // Set the status bar item's title.
          button.attributedTitle = self.attributedTitle(withPercentage: percentage)
      }
    } catch {
      print(error)
    }
    // Define the image as template.
    if let img = button.image {
      img.template = true
    }
  }

  ///  Creates an attributed string for the status bar item.
  ///
  ///  - parameter percent: Current percentage of the battery's charging status.
  private func attributedTitle(withPercentage percent: Int) -> NSAttributedString {
    // Define some attributes to make the status item look like Apple's battery gauge.
    let attrs = [NSFontAttributeName : NSFont.systemFontOfSize(12.0),
       NSBaselineOffsetAttributeName : 1.0]
    let title = "\(percent) %"
    return NSAttributedString(string: title, attributes: attrs)
  }
}