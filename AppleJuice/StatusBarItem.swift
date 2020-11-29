//
// StatusIcon.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa

final class StatusBarItem: NSObject {
    // MARK: Lifecycle

    /// Creates a new battery status bar item object.
    ///
    /// - parameter action: The action to be triggered, when the user clicks on the status bar item.
    /// - parameter target: The target that implements the supplied action.
    init(forBattery battery: BatteryService?, withAction action: Selector?, forTarget target: AnyObject?) {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.target = target
        item.action = action
        icon = StatusBarIcon()
        super.init()
    }

    /// Creates a status bar item object for a specific error.
    ///
    /// - parameter error: The error that occured.
    /// - parameter action: The action to be triggered, when the user clicks on the status bar item.
    /// - parameter target: The target that implements the supplied action.
    convenience init(forError error: BatteryError?, withAction action: Selector?, forTarget target: AnyObject?) {
        self.init(forBattery: nil, withAction: action, forTarget: target)

        guard let btn = item.button else {
            return
        }
        btn.image = icon?.drawBatteryImage(forError: error)
    }

    // MARK: Public

    /// Update the status bar items title and icon.
    ///
    /// - parameter battery: The battery object, to update the status bar item for.
    public func update(batteryInfo battery: BatteryService?) {
        setBatteryIcon(battery)
        setTitle(battery)
    }

    /// Displays the supplied menu object when the user clicks on the status bar item.
    ///
    /// - parameter menu: The menu object to display to the user.
    public func popUpMenu(_ menu: NSMenu) {
        item.popUpMenu(menu)
    }

    // MARK: Private

    private let item: NSStatusItem!
    private var icon: StatusBarIcon?

    /// Sets the status bar item's battery icon.
    ///
    /// - parameter batter: The battery to render the status bar icon for.
    private func setBatteryIcon(_ battery: BatteryService?) {
        guard let batteryState = battery?.state,
              let button = item.button
        else {
            return
        }

        if UserPreferences.hideBatteryIcon {
            button.image = nil
        } else {
            button.image = icon?.drawBatteryImage(forStatus: batteryState)
            button.imagePosition = .imageRight
        }
    }

    /// Sets the status bar item's title
    ///
    /// - parameter battery: The battery to build the status bar title for.
    private func setTitle(_ battery: BatteryService?) {
        guard let button = item.button,
              let percentage = battery?.percentage.formatted,
              let timeRemaining = battery?.timeRemaining.formatted
        else {
            return
        }

        let titleAttributes = [NSAttributedString.Key.font: NSFont.menuBarFont(ofSize: 11.0)]

        button.attributedTitle = NSAttributedString(string: "")
        if UserPreferences.showTime {
            button.attributedTitle = NSAttributedString(string: timeRemaining, attributes: titleAttributes)
        } else {
            button.attributedTitle = NSAttributedString(string: percentage, attributes: titleAttributes)
        }
    }
}
