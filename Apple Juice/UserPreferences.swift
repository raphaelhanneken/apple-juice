//
// UserPreferences.swift
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

/// Manages the user preferences.
final class UserPreferences {

  /// Holds a reference to the standart user defaults.
  private let userDefaults = NSUserDefaults.standardUserDefaults()

  /// Display the current charging status as time remaining? Default: Percentage.
  var showTime: Bool {
    get { return userDefaults.boolForKey(showTimeKey) }
    set { userDefaults.setBool(newValue, forKey: showTimeKey) }
  }

  /// Notify the user at five percent left.
  var fivePercentNotification: Int {
    get { return userDefaults.integerForKey(fivePercentNotificationKey) }
  }

  /// Notify the user at ten percent left.
  var tenPercentNotification: Int {
    get { return userDefaults.integerForKey(tenPercentNotificationKey) }
  }

  /// Notify the user at fifeteen percent left.
  var fifeteenPercentNotification: Int {
    get { return userDefaults.integerForKey(fifeteenPercentNotificationKey) }
  }

  /// Notify the user at twenty percent left.
  var twentyPercentNotification: Int {
    get { return userDefaults.integerForKey(twentyPercentNotificationKey) }
  }

  /// Notify the user when the battery is fully charged.
  var hundredPercentNotification: Int {
    get { return userDefaults.integerForKey(hundredPercentNotificationKey) }
  }

  /// Saves the NotificationKey the user was last informed of.
  var lastNotified: NotificationKey? {
    get { return NotificationKey(rawValue: userDefaults.integerForKey(lastNotifiedKey)) }
    set {
      if let notificationKey = newValue {
        userDefaults.setInteger(notificationKey.rawValue, forKey: lastNotifiedKey)
      }
    }
  }

  /// A set of all notifications the user is interested in.
  var notifications: Set<NotificationKey> {
    // Create an empty set.
    var result: Set<NotificationKey> = []

    // Check for notification settings.
    if fivePercentNotification == 1 {
      result.insert(.FivePercent)
    }
    if tenPercentNotification == 1 {
      result.insert(.TenPercent)
    }
    if fifeteenPercentNotification == 1 {
      result.insert(.FifeteenPercent)
    }
    if twentyPercentNotification == 1 {
      result.insert(.TwentyPercent)
    }
    if hundredPercentNotification == 1 {
      result.insert(.HundredPercent)
    }

    return result
  }

  // MARK: Methods

  init() {
    registerUserDefaults()
  }

  ///  Register user defaults.
  private func registerUserDefaults() {
    let defaults: Dictionary<String, AnyObject> = [showTimeKey : false,
      fivePercentNotificationKey : 0, tenPercentNotificationKey : 0,
      fifeteenPercentNotificationKey : 0, twentyPercentNotificationKey : 0,
      lastNotifiedKey : 0]

    userDefaults.registerDefaults(defaults)
  }
}

// MARK: Preference Constants

/// Show time preference key.
private let showTimeKey                    = "ShowTimePref"
/// Five percent notification preference key.
private let fivePercentNotificationKey     = "FivePercentNotificationPref"
/// Ten percent notification preference key.
private let tenPercentNotificationKey      = "TenPercentNotificationPref"
/// Fifeteen percent notification preference key.
private let fifeteenPercentNotificationKey = "FifeteenPercentNotificationPref"
/// Twenty percent notification preference key.
private let twentyPercentNotificationKey   = "TwentyPercentNotificationPref"
/// Hundred percent notification preference key.
private let hundredPercentNotificationKey  = "HundredPercentNotificationPref"
/// Save the percentage when the user was last notified.
private let lastNotifiedKey                = "LastNotifiedPref"
