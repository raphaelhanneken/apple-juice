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
final class UserPreferences: NSObject {

  /// Holds a reference to the standart user defaults.
  private let userDefaults = UserDefaults.standard

  /// Display the current charging status as time remaining? Default: Percentage.
  var showTime: Bool {
    return userDefaults.bool(forKey: PreferenceKey.showTime.rawValue)
  }

  /// Notify the user at five percent left.
  var fivePercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.fivePercentNotification.rawValue)
  }

  /// Notify the user at ten percent left.
  var tenPercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.tenPercentNotification.rawValue)
  }

  /// Notify the user at fifeteen percent left.
  var fifeteenPercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.fifeteenPercentNotification.rawValue)
  }

  /// Notify the user at twenty percent left.
  var twentyPercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.twentyPercentNotification.rawValue)
  }

  /// Notify the user when the battery is fully charged.
  var hundredPercentNotification: Int {
    return userDefaults.integer(forKey: PreferenceKey.hundredPercentNotification.rawValue)
  }

  /// Saves the NotificationKey the user was last informed of.
  var lastNotified: NotificationKey? {
    get { return NotificationKey(rawValue: userDefaults.integer(forKey: PreferenceKey.lastNotification.rawValue)) }
    set {
      if let notificationKey = newValue {
        userDefaults.set(notificationKey.rawValue, forKey: PreferenceKey.lastNotification.rawValue)
      }
    }
  }

  /// A set of all notifications the user is interested in.
  var notifications: Set<NotificationKey> {
    // Create an empty set.
    var result: Set<NotificationKey> = []
    // Check for notification settings.
    if fivePercentNotification == 1 {
      result.insert(.fivePercent)
    }
    if tenPercentNotification == 1 {
      result.insert(.tenPercent)
    }
    if fifeteenPercentNotification == 1 {
      result.insert(.fifeteenPercent)
    }
    if twentyPercentNotification == 1 {
      result.insert(.twentyPercent)
    }
    if hundredPercentNotification == 1 {
      result.insert(.hundredPercent)
    }
    return result
  }

  // MARK: - Methods

  ///  Initialize the user preferences object.
  override init() {
    super.init()
    registerUserDefaults()
  }

  ///  Register user defaults.
  private func registerUserDefaults() {
    let defaults = [PreferenceKey.showTime.rawValue : false,
                    PreferenceKey.fivePercentNotification.rawValue : 0,
                    PreferenceKey.tenPercentNotification.rawValue : 0,
                    PreferenceKey.fifeteenPercentNotification.rawValue : 0,
                    PreferenceKey.twentyPercentNotification.rawValue : 0,
                    PreferenceKey.hundredPercentNotification.rawValue : 0,
                    PreferenceKey.lastNotification.rawValue : 0]

    userDefaults.register(defaults)
  }
}


// MARK: - Preference Keys

///  Define keys to access the user preferences.
///
///  - showTime:                    Saves whether the user wants to see the remaining time within the menu bar.
///  - fivePercentNotification:     Saves if the user wants to get notified at   5%.
///  - tenPercentNotification:      Saves if the user wants to get notified at  10%.
///  - fifeteenPercentNotification: Saves if the user wants to get notified at  15%.
///  - twentyPercentNotification:   Saves if the user wants to get notified at  20%.
///  - hundredPercentNotification:  Saves if the user wants to get notified at 100%.
///  - lastNotification:            Saves at what percentage the user was last notified.
internal enum PreferenceKey: String {
  case showTime                    = "ShowTimePref"
  case fivePercentNotification     = "FivePercentNotificationPref"
  case tenPercentNotification      = "TenPercentNotificationPref"
  case fifeteenPercentNotification = "FifeteenPercentNotificationPref"
  case twentyPercentNotification   = "TwentyPercentNotificationPref"
  case hundredPercentNotification  = "HundredPercentNotificationPref"
  case lastNotification            = "LastNotifiedPref"
}
