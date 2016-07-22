//
// NotificationController.swift
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

/// Methods to post user notifications about the current charging status.
struct NotificationController {

  ///  Post a user notification based on the supplied notification key.
  ///
  ///  - parameter percentage: notification key for the current charging status.
  static func postUserNotification(forPercentage percentage: NotificationKey) {
    // Post a pluggedAndCharged notification at hundred percent; a lowPercentage
    // notification otherwise.
    if percentage == .hundredPercent {
      pluggedAndChargedNotification()
    } else {
      lowPercentageNotification(forPercentage: percentage)
    }
  }

  ///  Posts a plugged and charged user notification.
  private static func pluggedAndChargedNotification() {
    // Create a new user notification.
    let notification = NSUserNotification()
    // Configure the notification.
    notification.title = NSLocalizedString("Charged Notification Title",
                                           comment: "Translate the notification title.")

    notification.informativeText = NSLocalizedString("Charged Notification Message",
                                                     comment: "Translate the notification message.")
    // Deliver notification.
    NSUserNotificationCenter.default.deliver(notification)
  }

  ///  Posts a low percentage user notification.
  ///
  ///  - parameter percentage: The current percentage.
  private static func lowPercentageNotification(forPercentage percentage: NotificationKey) {
    // Create a new user notification.
    let notification = NSUserNotification()
    // Configure the notification.
    notification.title = NSLocalizedString("Low Battery Notification Title",
                                           comment: "Translate the notification title.")

    notification.informativeText = NSLocalizedString("Low Battery Notification Message",
                                                     comment: "Translate the notification message.")
    // Deliver notification.
    NSUserNotificationCenter.default.deliver(notification)
  }
}

// MARK: - NotificationKey's

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
