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
class NotificationController {

  ///  Posts a plugged and charged user notification.
  static func pluggedAndChargedNotification() {
    // Create a new user notification.
    let notification = NSUserNotification()
    // Configure the notification.
    notification.title = "Charged"
    notification.informativeText = "Your battery is now fully charged."
    // Deliver notification.
    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
  }

  ///  Posts a low percentage user notification.
  ///
  ///  - parameter percentage: The current percentage.
  static func lowPercentageNotification(forPercentage percentage: NotificationKey) {
    // Create a new user notification.
    let notification = NSUserNotification()
    // Configure the notification.
    notification.title = "Low Battery"
    notification.informativeText = "Your Mac will sleep soon unless plugged into a power outlet."
    // Deliver notification.
    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
  }
}

// MARK: NotificationKey's

///  Defines a notification at a given percentage.
///
///  - fivePercent:     Five percent notification.
///  - tenPercent:      Ten percent notification.
///  - fifeteenPercent: Fifeteen percent notification.
///  - twentyPercent:   Twenty percent notification.
///  - hundredPercent:  Hundred percent notification.
enum NotificationKey: Int {
  case None            = 0
  case FivePercent     = 5
  case TenPercent      = 10
  case FifeteenPercent = 15
  case TwentyPercent   = 20
  case HundredPercent  = 100
}
