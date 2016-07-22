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

final class ApplicationController: NSObject {
  /// Holds a reference to the application menu.
  @IBOutlet weak var applicationMenu: NSMenu!
  /// Holds a reference to the charging status menu item.
  @IBOutlet weak var currentCharge: NSMenuItem!
  /// Holds a reference to the power source menu item.
  @IBOutlet weak var currentSource: NSMenuItem!

  /// Holds the applications status bar item.
  private var statusItem: NSStatusItem!
  /// Manage the user preferences.
  private var userPrefs: UserPreferences!
  /// Access the battery information.
  private var battery: Battery!


  // MARK: - Methods

  override init() {
    // Initialize our parent class.
    super.init()

    // Initialize the user preferences.
    userPrefs  = UserPreferences()
    // Configure the status bar item.
    statusItem = configureStatusItem()

    do {
      // Get access to the battery information.
      try battery = Battery()
      // Get notified, when the power source changes.
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(ApplicationController.powerSourceChanged(_:)),
                                             name: NSNotification.Name(rawValue: powerSourceChangedNotification),
                                             object: nil)

      // Get notified, when the user toggles between time and percentage.
      UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showTime.rawValue,
                                        options: .new, context: nil)
    } catch {
      // Draw a status item for the catched battery error.
      drawBatteryIcon(forError: error as? BatteryError)
    }
  }

  ///  Gets called whenever the power source changes. Calls updateMenuItem:
  ///  and postUserNotification.
  ///
  ///  - parameter sender: Object that send the message.
  func powerSourceChanged(_ sender: AnyObject) {
    // Update status bar item to reflect changes.
    updateStatusItem()
    // Check if the user wants to get notified.
    postUserNotification()
  }

  /// Gets called everytime the ShowTimePref key changes.
  override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?,
                             change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
    // Update the status item to reflect the user defaults updates.
    updateStatusItem()
  }

  ///  Displays the app menu on screen.
  ///
  ///  - parameter sender: The object that send the message.
  func displayAppMenu(_ sender: AnyObject) {
    // Before showing the app menu, update the information displayed
    // within it.
    updateMenuItems({
      self.statusItem.popUpMenu(self.applicationMenu)
    })
  }


  // MARK: - Private Methods

  ///  Creates and configures the app's status bar item.
  ///
  ///  - returns: The application's status bar item.
  private func configureStatusItem() -> NSStatusItem {
    // Find a place to life.
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    // Set the status bar item properties.
    statusItem.target = self
    statusItem.action = #selector(ApplicationController.displayAppMenu(_:))

    return statusItem
  }

  ///  Updates the application's status bar item.
  private func updateStatusItem() {
    // Unwrap everything we need here...
    guard let button = statusItem.button,
      plugged        = battery.isPlugged,
      charging       = battery.isCharging,
      charged        = battery.isCharged,
      percentage     = battery.percentage else {
        return
    }
    // ...and draw the appropriate status bar icon.
    if charged && plugged {
      button.image = StatusIcon.batteryChargedAndPlugged
    } else if charging {
      button.image = StatusIcon.batteryCharging
    } else {
      button.image = StatusIcon.batteryDischarging(currentPercentage: percentage)
    }
    // Draw the status icon on the right hand side.
    button.imagePosition = .imageRight
    // Set the status bar item's title.
    button.attributedTitle = statusBarItemTitle(withPercentage: percentage,
                                                andTime: battery.timeRemainingFormatted)
    // Define the image as template.
    button.image?.isTemplate = true
  }

  ///  Updates the information within the app menu.
  ///
  ///  - parameter completionHandler: A callback function, that should get called
  ///                                 as soon as the menu items are updated.
  private func updateMenuItems(_ completionHandler: () -> Void) {
    // Unwrap the necessary battery information.
    guard let
      capacity   = battery.capacity,
      charge     = battery.charge,
      percentage = battery.percentage else {
        return
    }
    // Set the menu item title for the current charge level.
    if userPrefs.showTime {
      currentCharge.title = "\(percentage) % (\(charge) / \(capacity) mAh)"
    } else {
      currentCharge.title = battery.timeRemainingFormatted + " (\(charge) / \(capacity) mAh)"
    }
    // Set the menu item title for the current power source.
    currentSource.title = NSLocalizedString("Power Source", comment: "Translate Sourc") + " \(battery.powerSource)"

    // Run the supplied completion handler.
    completionHandler()
  }

  ///  Checks if the user wants to get notified about the current charging status.
  private func postUserNotification() {
    // Unwrap the necessary information.
    guard let plugged    = battery.isPlugged,
              charged    = battery.isCharged,
              percentage = battery.percentage else {
        return
    }
    // Define a new notification key.
    let notificationKey: NotificationKey?
    // Check what kind of notification key we have here.
    if plugged && charged {
      notificationKey = NotificationKey.hundredPercent
    } else if !plugged {
      notificationKey = NotificationKey(rawValue: percentage)
    } else {
      notificationKey = NotificationKey.invalid
    }
    // Unwrap the notification key and return if the current percentage isn't a valid notification key
    // or if we already posted a notification for the current percentage.
    guard let key = notificationKey where key != .invalid && key != userPrefs.lastNotified else {
      return
    }
    // Post the notification and save it as last notified.
    if userPrefs.notifications.contains(key) {
      NotificationController.postUserNotification(forPercentage: key)
    }
    userPrefs.lastNotified = key
  }

  ///  Creates an attributed string for the status bar item's title.
  ///
  ///  - parameter percent: Current percentage of the battery's charging status.
  ///  - parameter time:    The estimated remaining time in a human readable format.
  ///  - returns:           The attributed string with percentage or time information, respectively.
  private func statusBarItemTitle(withPercentage percent: Int, andTime time: String) -> AttributedString {
    // Define some attributes to make the status bar item look like Apple's battery gauge.
    let attrs = [NSFontAttributeName : NSFont.menuBarFont(ofSize: 12.0)]
    // Check whether the user wants to see the remaining time or not.
    if userPrefs.showTime {
      return AttributedString(string: "\(time) ", attributes: attrs)
    } else {
      return AttributedString(string: "\(percent) % ", attributes: attrs)
    }
  }

  ///  Display a battery error.
  ///
  ///  - parameter type: The BatteryError that was thrown.
  private func drawBatteryIcon(forError err: BatteryError?) {
    // Unwrap the menu bar item's button.
    guard let error = err, button = statusItem.button else {
        return
    }
    // Get the right icon and set an error message for the supplied error
    switch error {
    case .connectionAlreadyOpen:
      button.image = StatusIcon.batteryConnectionAlreadyOpen
    case .serviceNotFound:
      button.image = StatusIcon.batteryServiceNotFound
    }
    // Define the image as template
    button.image?.isTemplate = true
  }


  // MARK: - IBAction's

  ///  Open the energy saver preference pane.
  ///
  ///  - parameter sender: The menu item that send the message.
  @IBAction func energySaverPreferences(_ sender: NSMenuItem) {
    NSWorkspace.shared().openFile("/System/Library/PreferencePanes/EnergySaver.prefPane")
  }
}
