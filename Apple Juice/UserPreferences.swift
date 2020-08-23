//
// UserPreferences.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

///  Manages the user preferences.
final class UserPreferences: NSObject {

    ///  Holds a reference to the standard user defaults.
    private static let userDefaults = UserDefaults.standard

    ///  True if the user wants the remaining time to be displayed within the menu bar.
    static var showTime: Bool {
        return userDefaults.bool(forKey: PreferenceKey.showTime.rawValue)
    }

    ///  Hide all menu bar information
    static var hideMenubarInfo: Bool {
        return userDefaults.bool(forKey: PreferenceKey.hideMenubarInfo.rawValue)
    }

    ///  Hide all menu bar information
    static var hideBatteryIcon: Bool {
        return userDefaults.bool(forKey: PreferenceKey.hideBatteryIcon.rawValue)
    }

    ///  True if the user wants a notification at five percent.
    static var fivePercentNotification: Bool {
        return userDefaults.bool(forKey: PreferenceKey.fivePercentNotification.rawValue)
    }

    ///  True if the user wants a notification at ten percent.
    static var tenPercentNotification: Bool {
        return userDefaults.bool(forKey: PreferenceKey.tenPercentNotification.rawValue)
    }

    ///  True if the user wants a notification at fifeteen percent.
    static var fifeteenPercentNotification: Bool {
        return userDefaults.bool(forKey: PreferenceKey.fifeteenPercentNotification.rawValue)
    }

    ///  True if the user wants a notification at twenty percent.
    static var twentyPercentNotification: Bool {
        return userDefaults.bool(forKey: PreferenceKey.twentyPercentNotification.rawValue)
    }
    ///  True if the user wants a notification at forty percent.
    static var fortyPercentNotification: Bool {
        return userDefaults.bool(forKey: PreferenceKey.fortyPercentNotification.rawValue)
    }
    ///  True if the user wants a notification at eighty percent.
    static var eightyPercentNotification: Bool {
        return userDefaults.bool(forKey: PreferenceKey.eightyPercentNotification.rawValue)
    }

    ///  True if the user wants a notification at hundred percent.
    static var hundredPercentNotification: Bool {
        return userDefaults.bool(forKey: PreferenceKey.hundredPercentNotification.rawValue)
    }

    ///  Keeps the percentage the user was last notified.
    static var lastNotified: NotificationKey? {
        get {
            return NotificationKey(rawValue: userDefaults.integer(forKey: PreferenceKey.lastNotification.rawValue))
        }
        set {
            guard let notificationKey = newValue else {
                return
            }
            userDefaults.set(notificationKey.rawValue, forKey: PreferenceKey.lastNotification.rawValue)
        }
    }

    /// A set of all percentages where the user is interested.
    static var notifications: Set<NotificationKey> {
        // Create an empty set.
        var result: Set<NotificationKey> = []
        // Check the users notification settings and
        // add enabled notifications to the result set.
        if fivePercentNotification {
            result.insert(.fivePercent)
        }
        if tenPercentNotification {
            result.insert(.tenPercent)
        }
        if fifeteenPercentNotification {
            result.insert(.fifeteenPercent)
        }
        if twentyPercentNotification {
            result.insert(.twentyPercent)
        }
        if fortyPercentNotification {
            result.insert(.fortyPercent)
        }
        if eightyPercentNotification {
            result.insert(.eightyPercent)
        }
        if hundredPercentNotification {
            result.insert(.hundredPercent)
        }
        return result
    }

    // MARK: - Methods

    ///  Register user defaults.
    static func registerDefaults() {
        let defaultPreferences = [
            PreferenceKey.showTime.rawValue: true,
            PreferenceKey.fivePercentNotification.rawValue: false,
            PreferenceKey.tenPercentNotification.rawValue: false,
            PreferenceKey.fifeteenPercentNotification.rawValue: true,
            PreferenceKey.twentyPercentNotification.rawValue: false,
            PreferenceKey.fortyPercentNotification.rawValue: false,
            PreferenceKey.eightyPercentNotification.rawValue: false,
            PreferenceKey.hundredPercentNotification.rawValue: true,
            PreferenceKey.lastNotification.rawValue: 0,
            PreferenceKey.hideMenubarInfo.rawValue: false,
        ] as [String: Any]

        userDefaults.register(defaults: defaultPreferences)
    }
}
