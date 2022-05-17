//
// ApplicationController.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa
import LaunchAtLogin

final class ApplicationController: NSObject {

    private var statusItem: StatusBarItem?
    private var battery: BatteryService!
    private let notificationSubmenu = NotificationSubmenu()
    
    @IBOutlet weak var applicationMenu: NSMenu!

    @objc dynamic var launchAtLogin = LaunchAtLogin.kvo

    override init() {
        super.init()

        do {
            battery = try BatteryService()
            statusItem = StatusBarItem(forBattery: battery,
                                       withAction: #selector(ApplicationController.displayAppMenu(_:)),
                                       forTarget: self)
            statusItem?.update(batteryInfo: battery)
            

            // Register the ApplicationController as observer for power source and user preference changes
            UserDefaults
                .standard
                .addObserver(self, forKeyPath: PreferenceKey.showTimeBat.rawValue, options: .new, context: nil)
            
            UserDefaults
                .standard
                .addObserver(self, forKeyPath: PreferenceKey.showTimeCharge.rawValue, options: .new, context: nil)
            
            UserDefaults
                .standard
                .addObserver(self, forKeyPath: PreferenceKey.showPercentageETA.rawValue, options: .new, context: nil)
            
            UserDefaults
                .standard
                .addObserver(self, forKeyPath: PreferenceKey.percentagesNotifications.rawValue, options: .new, context: nil)

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
        } catch {
            statusItem = StatusBarItem(
                forError: error as? BatteryError,
                withAction: #selector(ApplicationController.displayAppMenu(_:)),
                forTarget: self)
        }
    }

    // MARK: Public

    /// This message is sent to the receiver, when a powerSourceChanged message was posted. The receiver
    /// must be registered as an observer for powerSourceChangedNotification's.
    ///
    /// - parameter sender: The object that posted powerSourceChanged message.
    @objc public func powerSourceChanged(_: AnyObject) {
        statusItem?.update(batteryInfo: battery)

        if let notification = StatusNotification(forState: battery.state) {
            notification.postNotification()
        }
    }

    /// Displays the application menu when the user clicks the menu bar item.
    ///
    /// - parameter sender: The object that sent the message.
    @objc public func displayAppMenu(_: AnyObject) {
        statusItem?.popUpMenu(applicationMenu)
    }

    
    // MARK: Internal

    /// This message is sent to the receiver when the value at the specified key path relative to the given object
    /// has changed. The receiver must be registered as an observer for the specified keyPath and object.
    ///
    /// - parameter keyPath: The key path, relative to object, to the value that has changed.
    /// - parameter object: The source object of the key path.
    /// - parameter change: A dictionary that describes the changes that have been made to
    ///                     the value of the property at the key path keyPath relative to object.
    ///                     Entries are described in Change Dictionary Keys.
    /// - parameter context: The value that was provided when the receiver was registered to receive key-value
    ///                      observation notifications.
    override func observeValue(forKeyPath _: String?,
                               of _: Any?,
                               change _: [NSKeyValueChangeKey: Any]?,
                               context _: UnsafeMutableRawPointer?)
    {
        statusItem?.update(batteryInfo: battery)
        notificationSubmenu.update(mainMenu: applicationMenu)
    }
}
