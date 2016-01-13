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
class UserPreferences {

  /// Holds a reference to the standart user defaults.
  private let userDefaults = NSUserDefaults.standardUserDefaults()

  /// Display the current charging status as time remaining? Default: Percentage.
  var showTime: Bool {
    get { return userDefaults.boolForKey(ShowTimeKey) }
    set { userDefaults.setBool(newValue, forKey: ShowTimeKey) }
  }

  /// Notify the user at five percent left.
  var fivePercentNotification: Bool {
    get { return userDefaults.boolForKey(FivePercentNotificationKey) }
  }

  /// Notify the user at ten percent left.
  var tenPercentNotification: Bool {
    get { return userDefaults.boolForKey(TenPercentNotificationKey) }
  }

  /// Notify the user at fifeteen percent left.
  var fifeteenPercentNotification: Bool {
    get { return userDefaults.boolForKey(FifeteenPercentNotificationKey) }
  }

  /// Notify the user at twenty percent left.
  var twentyPercentNotification: Bool {
    get { return userDefaults.boolForKey(TwentyPercentNotificationKey) }
  }

  /// Notify the user when the battery is fully charged.
  var hundredPercentNotification: Bool {
    get { return userDefaults.boolForKey(HundredPercentNotificationKey) }
  }

  /// Saves the NotificationKey the user was last informed of.
  var lastNotified: NotificationKey? {
    get { return NotificationKey(rawValue: userDefaults.integerForKey(LastNotified)) }
    set {
      if let notificationKey = newValue {
        userDefaults.setInteger(notificationKey.rawValue, forKey: LastNotified)
      }
    }
  }

  // MARK: Methods

  init() {
    self.registerUserDefaults()
  }

  ///  Register user defaults.
  private func registerUserDefaults() {
    let defaults = [ShowTimeKey : false, FivePercentNotificationKey : false,
      TenPercentNotificationKey : false, FifeteenPercentNotificationKey : false,
      TwentyPercentNotificationKey : false]

    self.userDefaults.registerDefaults(defaults)
  }
}

// MARK: Preference Constants

/// Show time preference key.
private let ShowTimeKey = "ShowTimePref"
/// Five percent notification preference key.
private let FivePercentNotificationKey = "FivePercentNotificationPref"
/// Ten percent notification preference key.
private let TenPercentNotificationKey = "TenPercentNotificationPref"
/// Fifeteen percent notification preference key.
private let FifeteenPercentNotificationKey = "FifeteenPercentNotificationPref"
/// Twenty percent notification preference key.
private let TwentyPercentNotificationKey = "TwentyPercentNotificationPref"
/// Hundred percent notification preference key.
private let HundredPercentNotificationKey = "HundredPercentNotificationPref"
/// Save the percentage when the user was last notified.
private let LastNotified = "LastNotifiedPref"
