//
// StatusIcon.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa

/// A battery status bar item.
final class StatusBarItem: NSObject {

    /// The applications status bar item.
    private let item: NSStatusItem!

    /// The icon to display in the battery status bar item.
    private var icon = StatusBarIcon()

    /// The status bar items button.
    var button: NSButton? {
        return item.button
    }

    // MARK: - Methods

    /// Instantiate a new battery status bar item.
    ///
    /// - Parameters:
    ///   - target: The target that implements the supplied action.
    ///   - action: The action to be triggered, when the
    ///             user clicks the status bar item.
    init(forBattery battery: BatteryService?, withTarget target: AnyObject?, andAction action: Selector?) {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.target = target
        item.action = action

        super.init()
    }

    /// Instantiate a new battery status bar item, in case of an error.
    ///
    /// - Parameters:
    ///   - error: The error that occured.
    ///   - target: The target that implements the supplied action.
    ///   - action: The action to be triggered, when the 
    ///             user clicks the status bar item.
    convenience init(forError error: BatteryError?, withTarget target: AnyObject?, andAction action: Selector?) {
        self.init(forBattery: nil, withTarget: target, andAction: action)

        guard let btn = item.button else {
            return
        }
        btn.image = icon.drawBatteryImage(forError: error)
    }

    /// Update the status bar item.
    ///
    /// - Parameter battery: The battery object, with new information.
    func update(batteryInfo battery: BatteryService?) {
        guard
            let button        = item.button,
            let batteryState  = battery?.state,
            let timeRemaining = battery?.timeRemainingFormatted else {
                return
        }
        button.attributedTitle = title(withPercentage: batteryState.percentage,
                                       andTime: timeRemaining)

        button.image = icon.drawBatteryImage(forStatus: batteryState)
        button.imagePosition = .imageRight
    }

    /// Display the supplied menu when the user clicks on
    /// the status bar item.
    ///
    /// - Parameter menu: The menu to display the user.
    func popUpMenu(_ menu: NSMenu) {
        item.popUpMenu(menu)
    }

    // MARK: - Private

    ///  Creates an attributed string for the status bar item's title.
    ///
    ///  - parameter percent: The battery's current charging state.
    ///  - parameter time:    The estimated remaining time in a human readable format.
    ///  - returns:           The attributed title with percentage or time information, respectively.
    private func title(withPercentage percent: Int, andTime time: String) -> NSAttributedString {
        if UserPreferences.hideMenubarInfo {
            return NSAttributedString(string: "")
        }

        let attrs = [
            NSAttributedString.Key.font: NSFont.menuBarFont(ofSize: 12.0)
        ]
        if UserPreferences.showTime {
            return NSAttributedString(string: "\(time) ", attributes: attrs)
        }
        return NSAttributedString(string: "\(percent) % ", attributes: attrs)
    }
}
