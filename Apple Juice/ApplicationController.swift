//
// ApplicationController.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//
// The MIT License (MIT)
//
// Copyright (c) 2015 - 2017 Raphael Hanneken
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

    /// The status bar item.
    private var statusItem: BatteryStatusBarItem?

    /// Access the battery's IOService.
    private var battery: Battery!

    // MARK: - Methods

    ///  Initialize the ApplicationController.
    override init() {
        // Initialize the parent class.
        super.init()

        // Register user defaults.
        UserPreferences.registerUserDefaults()

        do {
            // Access the battery's IOService.
            try battery = Battery.instance()

            // Create the status bar item.
            statusItem = BatteryStatusBarItem(withTarget: self,
                                              andAction: #selector(ApplicationController.displayAppMenu(_:)))
            // Update the status bar item.
            statusItem?.update(batteryInfo: battery)

            // Listen for powerSourceChangedNotification's.
            NotificationCenter.default
                .addObserver(self,
                             selector: #selector(ApplicationController.powerSourceChanged(_:)),
                             name: NSNotification.Name(rawValue: powerSourceChangedNotification),
                             object: nil)

            // Get notified, when the user toggles between displaying time and percentage.
            UserDefaults.standard.addObserver(self, forKeyPath: PreferenceKey.showTime.rawValue,
                                              options: .new, context: nil)

        } catch {
            statusItem = BatteryStatusBarItem(forError: error as? BatteryError,
                                              withTarget: self,
                                              andAction: #selector(ApplicationController.displayAppMenu(_:)))
        }
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
    override func observeValue(forKeyPath _: String?, of _: Any?,
                               change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        // Update the status item to reflect updated user preferences.
        statusItem?.update(batteryInfo: battery)
    }

    ///  This message is sent to the receiver, when a powerSourceChanged message was posted. The receiver
    ///  must be registered as an observer for powerSourceChangedNotification's.
    ///
    ///  - parameter sender: The source object of the posted powerSourceChanged message.
    func powerSourceChanged(_: AnyObject) {
        // Update status bar item to reflect changes.
        statusItem?.update(batteryInfo: battery)
        // Notify the user about the current percentage.
        if let notification = StatusNotification(forState: battery.state) {
            notification.notifyUser()
        }
    }

    ///  Displays the application menu under the status bar item when the
    ///  user clicks the item.
    ///
    ///  - parameter sender: The source object that sent the message.
    func displayAppMenu(_: AnyObject) {
        // Before showing the app menu, update the information displayed
        // within it.
        updateMenuItems({
            self.statusItem?.popUpMenu(self.applicationMenu)
        })
    }

    // MARK: - Private

    ///  Updates the information within the application menu.
    ///
    ///  - parameter completionHandler: A callback function, that gets called
    ///                                 as soon as the menu items are updated.
    private func updateMenuItems(_ completionHandler: () -> Void) {
        guard
            let capacity   = battery.capacity,
            let charge     = battery.charge,
            let percentage = battery.percentage else {
                return
        }
        // Set the menu item title for the current charge level, depending on the user preferences
        // with the current percentage or remaining time, respectively.
        if UserPreferences.showTime {
            currentCharge.title = "\(percentage) % (\(charge) / \(capacity) mAh)"
        } else {
            currentCharge.title = "\(battery.timeRemainingFormatted) (\(charge) / \(capacity) mAh)"
        }
        // Set the menu item title for the current power source.
        currentSource.title = "\(NSLocalizedString("Power Source", comment: "")) \(battery.powerSource)"

        // Run the provided completion handler.
        completionHandler()
    }

    // MARK: - IBAction's

    ///  Open the energy saver preference pane.
    ///
    ///  - parameter sender: The menu item object that sent the message.
    @IBAction func energySaverPreferences(_: NSMenuItem) {
        NSWorkspace.shared().openFile("/System/Library/PreferencePanes/EnergySaver.prefPane")
    }
}
