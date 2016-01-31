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

final class ApplicationController {
  /// Holds a reference to the application menu.
  @IBOutlet weak var appMenu: NSMenu!
  /// Holds a reference to the charging status menu item.
  @IBOutlet weak var currentCharge: NSMenuItem!
  /// Holds a reference to the power source menu item.
  @IBOutlet weak var currentSource: NSMenuItem!

  /// Holds the app's status bar item.
  private var statusItem: NSStatusItem?
  /// Manage user preferences.
  private let userPrefs = UserPreferences()
  /// Access to battery information.
  private var battery: Battery?

  // MARK: Methods

  init() {
    // Configure the status bar item.
    statusItem = configureStatusItem()
    do {
      // Get access to the battery information.
      try battery = Battery()
      // Display the status bar item.
      updateStatusItem()
      // Listen for PowerSourceChanged notifications.
      NSNotificationCenter.defaultCenter().addObserver(self,
        selector: Selector("powerSourceChanged:"), name: powerSourceChangedNotification,
        object: nil)
    } catch {
      // Draw a status item for the catched battery error.
      batteryError(type: error as? BatteryError)
    }
  }

  ///  Gets called whenever the power source changes. Calls updateMenuItem:
  ///  and postUserNotification.
  ///  - parameter sender: Object that send the message.
  func powerSourceChanged(sender: AnyObject) {
    // Update status bar item to reflect changes.
    updateStatusItem()
    // Check if the user wants to get notified.
    postUserNotification()
  }

  ///  Displays the app menu on screen.
  ///
  ///  - parameter sender: The object that send the message.
  func displayAppMenu(sender: AnyObject) {
    // Update the information displayed within the app menu.
    updateMenuItems()
    // Show the application menu.
    if let statusItem = statusItem {
      statusItem.popUpStatusItemMenu(appMenu)
    }
  }

  // MARK: Private Methods

  ///  Creates and configures the app's status bar item.
  ///
  ///  - returns: The application's status bar item.
  private func configureStatusItem() -> NSStatusItem {
    // Find a place to life.
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    // Set properties.
    statusItem.target = self
    statusItem.action = Selector("displayAppMenu:")

    return statusItem
  }

  ///  Updates the application's status bar item.
  private func updateStatusItem() {
    // Unwrap the status item's button.
    guard let button = statusItem?.button, battery = battery else {
      return
    }

    // Unwrap the necessary information...
    if let plugged = battery.isPlugged(), charging = battery.isCharging(),
      charged = battery.isCharged(), percentage = battery.percentage() {
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
        button.attributedTitle = attributedTitle(withPercentage: percentage,
          andTime: battery.timeRemainingFormatted())
    }

    // Define the image as template.
    if let img = button.image {
      img.template = true
    }
  }

  ///  Updates the information within the app menu.
  private func updateMenuItems() {
    guard let battery = battery else {
      return
    }
    // Get the updated information and set them as item title.
    currentSource.title = "\(NSLocalizedString("source", comment: ""))"
      + " \(battery.currentSource())"
    // Check wether the user wants the remaining time or not.
    if userPrefs.showTime {
      if let percentage = battery.percentage() {
        currentCharge.title = "\(percentage) %"
      }
    } else {
      currentCharge.title = battery.timeRemainingFormatted()
    }
    // Unwrap additional information.
    if let charge = battery.currentCharge(), capacity = battery.maxCapacity() {
      currentCharge.title += " (\(charge) / \(capacity) mAh)"
    }
  }

  ///  Checks if the user wants to get notified about the current charging status.
  private func postUserNotification() {
    // Unwrap the necessary information.
    guard let battery = battery, percentage = battery.percentage(), plugged = battery.isPlugged(),
      charged = battery.isCharged(), charging = battery.isCharging() else {
        return
    }
    // Check if we're plugged and charged.
    if plugged && charged {
      // Does the user wants to get notified about the plugged & charged status?
      if userPrefs.notifications.contains(.HundredPercent)
        && userPrefs.lastNotified != .HundredPercent {
          // Post a plugged & charged notification.
          NotificationController.pluggedAndChargedNotification()
          // Save the hundredPercent notification key as last notified.
          userPrefs.lastNotified = .HundredPercent
      }
    } else if !charging {
      // Since we're not charging, check if we should post a low percentage notification.
      guard let notificationKey = NotificationKey(rawValue: percentage)
        where userPrefs.notifications.contains(notificationKey) else {
          return
      }
      // Check that we haven't already notified the user about the current percentage.
      if userPrefs.lastNotified != notificationKey {
        // Post a low percentage notification.
        NotificationController.lowPercentageNotification(forPercentage: notificationKey)
        // Set lastNotified to the current notification key.
        userPrefs.lastNotified = notificationKey
      }
    } else {
      // Reset the lastNotified property.
      userPrefs.lastNotified = .None
    }
  }

  ///  Creates an attributed string for the status bar item's title.
  ///
  ///  - parameter percent: Current percentage of the battery's charging status.
  ///  - parameter time:    The estimated remaining time in a human readable format.
  ///  - returns: The attributed string with percentage or time information, respectively.
  private func attributedTitle(withPercentage percent: Int, andTime time: String)
    -> NSAttributedString {
      // Define some attributes to make the status item look like Apple's battery gauge.
      let attrs = [NSFontAttributeName : NSFont.systemFontOfSize(12.0),
        NSBaselineOffsetAttributeName : 1.0]
      var title = "\(percent) % "
      // Set the title to the remaining time.
      if userPrefs.showTime {
        title = "\(time) "
      }
      return NSAttributedString(string: title, attributes: attrs)
  }

  ///  Display a battery error.
  ///
  ///  - parameter type: The BatteryError that was thrown.
  private func batteryError(type type: BatteryError?) {
    // Unwrap the menu bar item's button.
    guard let button = statusItem?.button, type = type else {
      return
    }
    // Get the right icon and set an error message for the supplied error
    switch type {
    case .ConnectionAlreadyOpen:
      button.image = StatusIcon.batteryDeadCropped
    case .ServiceNotFound:
      button.image = StatusIcon.batteryNone
    }
    // Define the image as template
    if let img = button.image {
      img.template = true
    }
  }

  // MARK: IBAction's

  ///  Show percentage instead of remaining time.
  ///
  ///  - parameter sender: Menu item that send the message.
  @IBAction func showPercentage(sender: NSMenuItem) {
    // Toggle the show time preference.
    userPrefs.showTime = false
    // Update the status bar item to reflect the changes.
    updateStatusItem()
  }

  ///  Show time remaining instead of percentage.
  ///
  ///  - parameter sender: Menu item that send the message.
  @IBAction func showTime(sender: NSMenuItem) {
    // Toggle the show time preference.
    userPrefs.showTime = true
    // Update the status bar item to reflect the changes.
    updateStatusItem()
  }

  ///  Open the energy saver preference pane.
  ///
  ///  - parameter sender: The menu item that send the message.
  @IBAction func energySaverPreferences(sender: NSMenuItem) {
    NSWorkspace.sharedWorkspace().openFile("/System/Library/PreferencePanes/EnergySaver.prefPane")
  }
}
