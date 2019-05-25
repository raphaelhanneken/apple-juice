//
// ApplicationController.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa

final class ApplicationController: NSObject {

    /// Holds a weak reference to the application menu.
    @IBOutlet weak var applicationMenu: NSMenu!
    /// Holds a weak reference to the charging status menu item.
    @IBOutlet weak var currentCharge: NSMenuItem!
    /// Holds a weak reference to the power source menu item.
    @IBOutlet weak var currentSource: NSMenuItem!

    /// The status bar item.
    private var statusItem: StatusBarItem?

    /// An abstraction to the battery IO service
    private var battery: BatteryService!

    override init() {
        super.init()
        do {
            self.battery = try BatteryService()
            self.statusItem = StatusBarItem(forBattery: self.battery,
                                            withTarget: self,
                                            andAction: #selector(ApplicationController.displayAppMenu(_:)))

            self.statusItem?.update(batteryInfo: self.battery)
            self.registerAsObserver()
        } catch {
            self.statusItem = StatusBarItem(forError: error as? BatteryError,
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
        statusItem?.update(batteryInfo: battery)
    }

    ///  This message is sent to the receiver, when a powerSourceChanged message was posted. The receiver
    ///  must be registered as an observer for powerSourceChangedNotification's.
    ///
    ///  - parameter sender: The source object of the posted powerSourceChanged message.
    @objc func powerSourceChanged(_: AnyObject) {
        statusItem?.update(batteryInfo: battery)
        if let notification = StatusNotification(forState: battery.state) {
            notification.postNotification()
        }
    }

    ///  Displays the application menu under the status bar item when the
    ///  user clicks the item.
    ///
    ///  - parameter sender: The source object that sent the message.
    @objc func displayAppMenu(_: AnyObject) {
        updateMenuItems({
            self.statusItem?.popUpMenu(self.applicationMenu)
        })
    }

    ///  Updates the information within the application menu.
    ///
    ///  - parameter completionHandler: A callback function, that gets called
    ///                                 as soon as the menu items are updated.
    private func updateMenuItems(_ completionHandler: () -> Void) {
        guard
            let capacity = battery.capacity,
            let charge   = battery.charge,
            let amperage = battery.amperage else {
                return
        }

        currentSource.title = "\(NSLocalizedString("Power Source", comment: "")) \(battery.powerSource)"
        currentCharge.title = "\(battery.timeRemainingFormatted) \(charge) / \(capacity) mAh (\(amperage) mA)"

        if UserPreferences.showTime {
            currentCharge.title = "\(battery.percentageFormatted) \(charge) / \(capacity) mAh (\(amperage) mA)"
        }
        completionHandler()
    }

    /// Register the ApplicationController as observer for changes in the power source and the user preferences
    private func registerAsObserver() {
        UserDefaults
            .standard
            .addObserver(self, forKeyPath: PreferenceKey.showTime.rawValue, options: .new, context: nil)

        UserDefaults
            .standard
            .addObserver(self, forKeyPath: PreferenceKey.hideMenubarInfo.rawValue, options: .new, context: nil)

        UserDefaults
            .standard
            .addObserver(self, forKeyPath: PreferenceKey.hideBatteryIcon.rawValue, options: .new, context: nil)

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(ApplicationController.powerSourceChanged(_:)),
                         name: NSNotification.Name(rawValue: powerSourceChangedNotification),
                         object: nil)
    }

    ///  Open the energy saver preference pane.
    ///
    ///  - parameter sender: The menu item object that sent the message.
    @IBAction func energySaverPreferences(_: NSMenuItem) {
        NSWorkspace.shared.openFile("/System/Library/PreferencePanes/EnergySaver.prefPane")
    }
}
