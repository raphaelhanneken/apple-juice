//
// StatusNotification.swift
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

import Foundation

/// Posts user notifications about the current charging status.
struct StatusNotification {
  /// The current notification's key.
  fileprivate let notificationKey: NotificationKey
  /// The notification title.
  fileprivate var title: String?
  /// The notification text.
  fileprivate var text: String?


  // MARK: - Methods

  /// Initializes a new StatusNotification.
  ///
  /// - parameter key: The notification key which to display a user notification for.
  /// - returns:       An optional StatusNotification; Return nil when the notificationKey
  ///                  is invalid or nil.
  init?(forNotificationKey key: NotificationKey?) {
    // Unwrap the provided notification key and bail out if it isn't a valid key.
    guard let key = key else {
      return nil
    }
    // Set the StatusNotification's properties.
    notificationKey = key
    setNotificationProperties()
  }

  /// Delivers a NSUserNotification to the user.
  ///
  /// - returns: The NotificationKey for the delivered notification.
  func post() -> NotificationKey {
    // Create a new user notification object.
    let notification = NSUserNotification()
    // Configure the new user notification.
    notification.title           = title
    notification.informativeText = text
    // Deliver the notification.
    NSUserNotificationCenter.default.deliver(notification)

    return notificationKey
  }


  // MARK: - Private

  /// Sets the user notifications informative text and title.
  private mutating func setNotificationProperties() {
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
                                                   comment: "The banner title for the low battery notification."),
                     notificationKey.rawValue)
      text  = NSLocalizedString("Low Battery Notification Message",
                                comment: "Translate the informative text for the low battery notification.")
    }
  }
}


// MARK: - NotificationKeys

///  Defines a notification at a given percentage.
///
///  - Invalid:         Not a valid notification percentage.
///  - FivePercent:     Five percent notification.
///  - TenPercent:      Ten percent notification.
///  - FifeteenPercent: Fifeteen percent notification.
///  - TwentyPercent:   Twenty percent notification.
///  - HundredPercent:  Hundred percent notification.
enum NotificationKey: Int {
  case invalid         = 0
  case fivePercent     = 5
  case tenPercent      = 10
  case fifeteenPercent = 15
  case twentyPercent   = 20
  case hundredPercent  = 100
}
