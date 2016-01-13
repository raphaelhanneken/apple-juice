//
// ApplicationController.swift
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
  /// Manage user preferences.
  let userPrefs = UserPreferences()

  // MARK: Methods

  override init() {
    // Initialize our parent class.
    super.init()
    // Configure the status bar item.
    self.statusItem = self.configureStatusItem()
    // Listen for PowerSourceChanged notifications, posted by self.battery.
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("powerSourceChanged:"),
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
    // Update the information displayed within the app menu.
    self.updateMenuItems()
    // Show the application menu.
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
          button.attributedTitle = self.attributedTitle(withPercentage: percentage,
            andTime: self.battery.timeRemainingFormatted())
      }
    } catch {
      print(error)
    }
    // Define the image as template.
    if let img = button.image {
      img.template = true
    }
  }

  ///  Updates the information within the app menu.
  func updateMenuItems() {
    do {
      // Try closing the IO connection in any case.
      defer { self.battery.close() }
      // Open an IO connection to the defined battery service.
      try self.battery.open()
      // Get the updated information and set them as item title.
      self.currentSource.title = "Source: \(self.battery.currentSource())"
      // Check wether the user wants the remaining time or not.
      if self.userPrefs.showTime {
        if let percentage = self.battery.percentage() {
          self.currentCharge.title = "\(percentage) %"
        }
      } else {
        self.currentCharge.title = self.battery.timeRemainingFormatted()
      }
      // Unwrap additional information.
      if let currentCharge = self.battery.currentCharge(),
        maxCapacity = self.battery.maxCapacity() {
          self.currentCharge.title += " (\(currentCharge) / \(maxCapacity) mAh)"
      }
    } catch {
      print(error)
    }
  }

  ///  Gets called whenever the power source changes. Calls updateMenuItem:
  ///  and postUserNotification.
  ///  - parameter sender: Object that send the message.
  func powerSourceChanged(sender: AnyObject) {
    // Update status bar item to reflect changes.
    self.updateStatusItem(self)
    // Check if the user wants to get notified.
    self.postUserNotification()
  }

  ///  Checks if the user wants to get notified about the current charging status.
  func postUserNotification() {
  }

  ///  Creates an attributed string for the status bar item.
  ///
  ///  - parameter percent: Current percentage of the battery's charging status.
  private func attributedTitle(withPercentage percent: Int,
    andTime time: String) -> NSAttributedString {
    // Define some attributes to make the status item look like Apple's battery gauge.
    let attrs = [NSFontAttributeName : NSFont.systemFontOfSize(12.0),
       NSBaselineOffsetAttributeName : 1.0]
    var title = "\(percent) % "
    // Set the title to the remaining time.
    if self.userPrefs.showTime {
      title = "\(time) "
    }
    return NSAttributedString(string: title, attributes: attrs)
  }

  // MARK: IBAction's

  ///  Show percentage instead of remaining time.
  ///
  ///  - parameter sender: Menu item that send the message.
  @IBAction func showPercentage(sender: NSMenuItem) {
    // Toggle the show time preference.
    self.userPrefs.showTime = false
    // Update the status bar item to reflect the changes.
    self.updateStatusItem(self)
  }

  ///  Show time remaining instead of percentage.
  ///
  ///  - parameter sender: Menu item that send the message.
  @IBAction func showTime(sender: NSMenuItem) {
    // Toggle the show time preference.
    self.userPrefs.showTime = true
    // Update the status bar item to reflect the changes.
    self.updateStatusItem(self)
  }

  ///  Open the energy saver preference pane.
  ///
  ///  - parameter sender: The menu item that send the message.
  @IBAction func energySaverPreferences(sender: NSMenuItem) {
    NSWorkspace.sharedWorkspace().openFile("/System/Library/PreferencePanes/EnergySaver.prefPane")
  }
}