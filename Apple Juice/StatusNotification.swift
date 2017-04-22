//
// StatusNotification.swift
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

import Foundation

/// Posts user notifications about the current charging status.
struct StatusNotification {
    /// The current notification's key.
    private let notificationKey: NotificationKey
    /// The notification title.
    private var title: String?
    /// The notification text.
    private var text: String?

    // MARK: - Methods

    /// Initializes a new StatusNotification.
    ///
    /// - parameter key: The notification key which to display a user notification for.
    /// - returns:       An optional StatusNotification; Return nil when the notificationKey
    ///                  is invalid or nil.
    init?(forState state: BatteryState?) {
        guard
            let state = state,
            let key = NotificationKey(rawValue: state.percentage),
                !(state == BatteryState.charging(percentage: 0)) else {
            // print("Not a valid percentage: \(state.percentage)")
            return nil
        }
        notificationKey = key
        setNotificationTitleAndText()
    }

    ///  Checks if the user wants to get notified about the current charging status.
    func notifyUser() {
        // Assure the user didn't already receive a notification about the current percentage and that
        // the user is actually interested in the current charging status.
        if notificationKey != UserPreferences.lastNotified && UserPreferences.notifications.contains(notificationKey) {
            post()
        }
    }

    /// Delivers a NSUserNotification to the user.
    ///
    /// - returns: The NotificationKey for the delivered notification.
    private func post() {
        // Create a new user notification object.
        let notification = NSUserNotification()
        // Configure the new user notification.
        notification.title = title
        notification.informativeText = text
        // Deliver the notification.
        NSUserNotificationCenter.default.deliver(notification)
        // Update the last notified preference.
        UserPreferences.lastNotified = notificationKey
    }

    // MARK: - Private

    /// Sets the user notifications informative text and title.
    private mutating func setNotificationTitleAndText() {
        switch notificationKey {
        case .invalid:
            return
        case .hundredPercent:
            title = NSLocalizedString("Charged Notification Title",
                                      comment: "Translate the banner title for the charged / 100 % notification.")
            text  = NSLocalizedString("Charged Notification Message",
                                      comment: "Translate the informative text for the charged / 100% notification.")
        default:
            title = String.localizedStringWithFormat(NSLocalizedString("Low Battery Notification Title",
                                                     comment: "Notification title: Low Battery."),
                                                     notificationKey.rawValue)
            text  = NSLocalizedString("Low Battery Notification Message",
                                      comment: "Translate the informative text for the low battery notification.")
        }
    }
}
