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
  private let userDefaults = UserDefaults.standard

  /// Display the current charging status as time remaining? Default: Percentage.
  var showTime: Bool {
    return userDefaults.bool(forKey: PreferenceKey.ShowTime.rawValue)
  }

  /// Notify the user at five percent left.
  var fivePercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.FivePercentNotification.rawValue)
  }

  /// Notify the user at ten percent left.
  var tenPercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.TenPercentNotification.rawValue)
  }

  /// Notify the user at fifeteen percent left.
  var fifeteenPercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.FifeteenPercentNotification.rawValue)
  }

  /// Notify the user at twenty percent left.
  var twentyPercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.TwentyPercentNotification.rawValue)
  }

  /// Notify the user when the battery is fully charged.
  var hundredPercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.HundredPercentNotification.rawValue)
  }

  /// Saves the NotificationKey the user was last informed of.
  var lastNotified: NotificationKey? {
    get { return NotificationKey(rawValue: userDefaults.integer(forKey: PreferenceKey.LastNotification.rawValue)) }
    set {
      if let notificationKey = newValue {
        userDefaults.set(notificationKey.rawValue, forKey: PreferenceKey.LastNotification.rawValue)
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

  // MARK: - Methods

  init() {
    registerUserDefaults()
  }

  ///  Register user defaults.
  private func registerUserDefaults() {
    let defaults = [PreferenceKey.ShowTime.rawValue : false,
                    PreferenceKey.FivePercentNotification.rawValue : 0,
                    PreferenceKey.TenPercentNotification.rawValue : 0,
                    PreferenceKey.FifeteenPercentNotification.rawValue : 0,
                    PreferenceKey.TwentyPercentNotification.rawValue : 0,
                    PreferenceKey.HundredPercentNotification.rawValue : 0,
                    PreferenceKey.LastNotification.rawValue : 0]

    userDefaults.register(defaults)
  }
}


// MARK: - Preference Keys

///  Define keys to access the user preferences.
///
///  - ShowTime:                    Saves whether the user wants to see the remaining time within the menu bar.
///  - FivePercentNotification:     Saves if the user wants to get notified at   5%.
///  - TenPercentNotification:      Saves if the user wants to get notified at  10%.
///  - FifeteenPercentNotification: Saves if the user wants to get notified at  15%.
///  - TwentyPercentNotification:   Saves if the user wants to get notified at  20%.
///  - HundredPercentNotification:  Saves if the user wants to get notified at 100%.
///  - LastNotification:            Saves at what percentage the user was last notified.
private enum PreferenceKey: String {
  case ShowTime                    = "ShowTimePref"
  case FivePercentNotification     = "FivePercentNotificationPref"
  case TenPercentNotification      = "TenPercentNotificationPref"
  case FifeteenPercentNotification = "FifeteenPercentNotificationPref"
  case TwentyPercentNotification   = "TwentyPercentNotificationPref"
  case HundredPercentNotification  = "HundredPercentNotificationPref"
  case LastNotification            = "LastNotifiedPref"
}
