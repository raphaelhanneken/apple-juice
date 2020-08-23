//
// StatusNotification.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

/// Posts user notifications about the current charging status.
struct StatusNotification {

    /// The current notification's key.
    private let notificationKey: NotificationKey

    /// Initializes a new StatusNotification.
    ///
    /// - parameter key: The notification key which to display a user notification for.
    /// - returns:       An optional StatusNotification; Return nil when the notificationKey
    ///                  is invalid or nil.
    init?(forState state: BatteryState?) {
        guard let state = state, state != .charging(percentage: 0) else {
            return nil
        }
        guard let key = NotificationKey(rawValue: state.percentage), key != .invalid else {
            return nil
        }
        self.notificationKey = key
    }

    /// Present a notification for the current battery status to the user
    func postNotification() {
        if self.shouldPresentNotification() {
            NSUserNotificationCenter.default.deliver(self.createUserNotification())
            UserPreferences.lastNotified = self.notificationKey
        }
    }

    // MARK: - Private

    /// Check whether to present a notification to the user or not. Depending on the
    /// users preferences and whether the user already got notified about the current
    /// percentage.
    ///
    /// - Returns: Whether to present a notification for the current battery percentage
    private func shouldPresentNotification() -> Bool {
        return (self.notificationKey != UserPreferences.lastNotified
            && UserPreferences.notifications.contains(self.notificationKey))
    }

    /// Create a user notification for the current battery status
    ///
    /// - Returns: The user notification to display
    private func createUserNotification() -> NSUserNotification {
        let notification = NSUserNotification()
        notification.title = self.getNotificationTitle()
        notification.informativeText = self.getNotificationText()

        return notification
    }

    /// Get the corresponding notification title for the current battery state
    ///
    /// - Returns: The notification title
    private func getNotificationTitle() -> String {
        if self.notificationKey == .hundredPercent {
            return NSLocalizedString("Charged Notification Title", comment: "")
        }
        else if self.notificationKey == .eightyPercent{
            return NSLocalizedString("Enough Battery For Battery Health", comment: "")
        }
        else if self.notificationKey == .fortyPercent{
            return NSLocalizedString("Low Battery For Battery Health", comment: "")
        }
        return String.localizedStringWithFormat(NSLocalizedString("Low Battery Notification Title", comment: ""),
                                                self.formattedPercentage())
    }

    /// Get the corresponding notification text for the current battery state
    ///
    /// - Returns: The notification text
    private func getNotificationText() -> String {
        if self.notificationKey == .hundredPercent {
            return NSLocalizedString("Charged Notification Message", comment: "")
        }
        else if self.notificationKey == .eightyPercent{
            return NSLocalizedString("Enough Battery For Battery Health", comment: "")
        }
        else if self.notificationKey == .fortyPercent{
            return NSLocalizedString("Low Battery For Battery Health", comment: "")
        }
        return NSLocalizedString("Low Battery Notification Message", comment: "")
    }

    /// The current percentage, formatted according to the selected client locale, e.g.
    /// en_US: 42% fr_FR: 42 %
    ///
    /// - Returns: The localised percentage
    private func formattedPercentage() -> String {
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.generatesDecimalNumbers = false
        percentageFormatter.localizesFormat = true
        percentageFormatter.multiplier = 1.0
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.maximumFractionDigits = 0

        return percentageFormatter.string(from: self.notificationKey.rawValue as NSNumber)
            ?? "\(self.notificationKey.rawValue) %"
    }
}
