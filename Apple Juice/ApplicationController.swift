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
  /// Holds a weak reference to the application menu.
  @IBOutlet weak var applicationMenu: NSMenu!
  /// Holds a weak reference to the charging status menu item.
  @IBOutlet weak var currentCharge: NSMenuItem!
  /// Holds a weak reference to the power source menu item.
  @IBOutlet weak var currentSource: NSMenuItem!

  /// Holds the applications status bar item.
  private var statusItem: NSStatusItem!
  /// Manages the user preferences.
  private var userPrefs  = UserPreferences()
  /// Generates the status bar item icons.
  private var statusIcon = StatusIcon()
  /// Access the battery's IOService.
  private var battery: Battery!


  // MARK: - Methods

  ///  Initialize the ApplicationController.
  override init() {
    // Initialize the parent class.
    super.init()

    do {
      // Access the battery's IOService.
      try battery = Battery()
      // Initialize the user preferences.
      userPrefs   = UserPreferences()
      // Configure and update the status bar item.
      configureStatusItem({
        self.updateStatusItem()
      })
      // Listen for powerSourceChangedNotification's.
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(ApplicationController.powerSourceChanged(_:)),
                                             name: NSNotification.Name(rawValue: powerSourceChangedNotification),
                                             object: nil)

      // Get notified, when the user toggles between displaying time and percentage.
      UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showTime.rawValue,
                                        options: .new, context: nil)

    } catch {
      guard let button = statusItem.button else {
        return
      }
      // Draw a status item for the catched battery error.
      button.image = statusIcon.drawBatteryImage(forError: error as? BatteryError)
    }
  }

  ///  This message is sent to the receiver, when a powerSourceChanged message was posted. The receiver
  ///  must be registered as an observer for powerSourceChangedNotification's.
  ///
  ///  - parameter sender: The source object of the posted powerSourceChanged message.
  func powerSourceChanged(_ sender: AnyObject) {
    // Update status bar item to reflect changes.
    updateStatusItem()
    // Check if the user wants to get notified.
    postUserNotification()
  }

  ///  This message is sent to the receiver when the value at the specified key
  ///  path relative to the given object has changed. The receiver must be
  ///  registered as an observer for the specified keyPath and object.
  ///
  ///  - parameter keyPath: The key path, relative to object, to the value that has changed.
  ///  - parameter object:  The source object of the key path.
  ///  - parameter change:  A dictionary that describes the changes that have been made to
  ///                       the value of the property at the key path keyPath relative to object.
  ///                       Entries are described in Change Dictionary Keys.
  ///  - parameter context: The value that was provided when the receiver was registered to receive key-value
  ///                       observation notifications.
  override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?,
                             change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
    // Update the status item to reflect updated user preferences.
    updateStatusItem()
  }

  ///  Displays the application menu under the status bar item when the
  ///  user clicks the item.
  ///
  ///  - parameter sender: The source object that sent the message.
  func displayAppMenu(_ sender: AnyObject) {
    // Before showing the app menu, update the information displayed
    // within it.
    updateMenuItems({
      self.statusItem.popUpMenu(self.applicationMenu)
    })
  }


  // MARK: - Private

  /// Creates and configures the application's status bar item.
  ///
  /// - parameter completionHandler: A callback function, that gets calles as
  ///                                soon as the status bar item is initialized.
  private func configureStatusItem(_ completionHandler: () -> Void) {
    // Find a place to life.
    let item = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    // Set the status bar item properties.
    item.target = self
    item.action = #selector(ApplicationController.displayAppMenu(_:))

    self.statusItem = item
    completionHandler()
  }

  ///  Updates the application's status bar item.
  private func updateStatusItem() {
    guard let
      button     = statusItem.button,
      status     = battery.status,
      percentage = battery.percentage else {
        return
    }
    // Set the attributed status bar item title.
    button.attributedTitle = statusBarItemTitle(withPercentage: percentage,
                                                andTime: battery.timeRemainingFormatted)

    // Draw the corresponding status bar image.
    button.image = statusIcon.drawBatteryImage(forStatus: status)
    // Set the image position relative to it's title.
    button.imagePosition = .imageRight
  }

  ///  Updates the information within the application menu.
  ///
  ///  - parameter completionHandler: A callback function, that gets called
  ///                                 as soon as the menu items are updated.
  private func updateMenuItems(_ completionHandler: () -> Void) {
    guard let
      capacity   = battery.capacity,
      charge     = battery.charge,
      percentage = battery.percentage else {
        return
    }
    // Set the menu item title for the current charge level, depending on the user preferences
    // with the current percentage or remaining time, respectively.
    if userPrefs.showTime {
      currentCharge.title = "\(percentage) % (\(charge) / \(capacity) mAh)"
    } else {
      currentCharge.title = "\(battery.timeRemainingFormatted) (\(charge) / \(capacity) mAh)"
    }
    // Set the menu item title for the current power source.
    currentSource.title = "\(NSLocalizedString("Power Source", comment: "Translte Source")) \(battery.powerSource)"

    // Run the provided completion handler.
    completionHandler()
  }

  ///  Creates an attributed string for the status bar item's title.
  ///
  ///  - parameter percent: The battery's current charging state.
  ///  - parameter time:    The estimated remaining time in a human readable format.
  ///  - returns:           The attributed title with percentage or time information, respectively.
  private func statusBarItemTitle(withPercentage percent: Int, andTime time: String) -> AttributedString {
    // Define some attributes to make the status bar item look more like Apple's battery gauge.
    let attrs = [NSFontAttributeName : NSFont.menuBarFont(ofSize: 12.0)]
    // Check whether the user wants to see the remaining time or not.
    if userPrefs.showTime {
      return AttributedString(string: "\(time) ", attributes: attrs)
    } else {
      return AttributedString(string: "\(percent) % ", attributes: attrs)
    }
  }

  ///  Checks if the user wants to get notified about the current charging status.
  private func postUserNotification() {
    // Get the current battery status.
    guard let batteryState = battery.status else {
      return
    }
    // Define a new NotificationKey.
    let notificationKey: NotificationKey?
    // Check in which state the battery currently is and set the
    // notificationKey accordingly.
    switch batteryState {
    case .discharging(let percentage):
      notificationKey = NotificationKey(rawValue: percentage)
    case .pluggedAndCharged:
      notificationKey = .hundredPercent
    default:
      if userPrefs.lastNotified != .invalid { userPrefs.lastNotified = .invalid }
      return
    }
    // Assure the user didn't already receive a notification about the current percentage and that
    // the user is actually interested in the current charging status.
    if let key = notificationKey where key != userPrefs.lastNotified && userPrefs.notifications.contains(key) {
      userPrefs.lastNotified = StatusNotification(forNotificationKey: key)?.post()
    }
  }


  // MARK: - IBAction's

  ///  Open the energy saver preference pane.
  ///
  ///  - parameter sender: The menu item object that sent the message.
  @IBAction func energySaverPreferences(_ sender: NSMenuItem) {
    NSWorkspace.shared().openFile("/System/Library/PreferencePanes/EnergySaver.prefPane")
  }
}
