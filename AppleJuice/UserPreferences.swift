//
// UserPreferences.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

/// Manages the user preferences.
final class UserPreferences: NSObject {
    // MARK: Internal

    /// True if the user wants the remaining time to be displayed within the menu bar while on battery.
    static var showTimeBat: Bool {
        userDefaults.bool(forKey: PreferenceKey.showTimeBat.rawValue)
    }
    
    /// True if the user wants the remaining time to be displayed within the menu bar while charging
    static var showTimeCharge: Bool {
        userDefaults.bool(forKey: PreferenceKey.showTimeCharge.rawValue)
    }
    
    static var showPercentageETA: Bool {
        userDefaults.bool(forKey: PreferenceKey.showPercentageETA.rawValue)
    }

    /// Hide all menu bar information
    static var hideMenubarInfo: Bool {
        userDefaults.bool(forKey: PreferenceKey.hideMenubarInfo.rawValue)
    }

    /// Hide all menu bar information
    static var hideBatteryIcon: Bool {
        userDefaults.bool(forKey: PreferenceKey.hideBatteryIcon.rawValue)
    }

    static var percentagesNotification: [Int] {
        userDefaults.object(forKey: PreferenceKey.percentagesNotifications.rawValue) as? [Int] ?? []
    }

    /// Keeps the percentage the user was last notified.
    static var lastNotified: Int? {
        get {
            userDefaults.integer(forKey: PreferenceKey.lastNotification.rawValue)
        }
        set {
            guard let newPercentage = newValue else {
                return
            }
            userDefaults.set(newPercentage, forKey: PreferenceKey.lastNotification.rawValue)
        }
    }

    /// Register user defaults.
    static func registerDefaults() {
        let defaultPreferences = [
            PreferenceKey.showTimeBat.rawValue: true,
            PreferenceKey.showTimeCharge.rawValue: true,
            PreferenceKey.showPercentageETA.rawValue: false,
            PreferenceKey.percentagesNotifications.rawValue: [15],
            PreferenceKey.lastNotification.rawValue: 0,
            PreferenceKey.hideMenubarInfo.rawValue: false,
        ] as [String: Any]

        userDefaults.register(defaults: defaultPreferences)
    }
    
    static func removeNotif(p: Int) {
        userDefaults.set(percentagesNotification.filter {$0 != p}, forKey: PreferenceKey.percentagesNotifications.rawValue)
    }
    
    static func addNotif(p: Int) {
        let newPercentages : [Int] = percentagesNotification+[p]
        userDefaults.set(newPercentages.sorted() , forKey: PreferenceKey.percentagesNotifications.rawValue)
    }

    // MARK: Private

    /// Holds a reference to the standard user defaults.
    private static let userDefaults = UserDefaults.standard
}
