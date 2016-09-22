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

///  Manages the user preferences.
final class UserPreferences: NSObject {

  ///  Holds a reference to the standard user defaults.
  fileprivate let userDefaults = UserDefaults.standard

  ///  True if the user wants the remaining time to be displayed within the menu bar.
  var showTime: Bool {
    return userDefaults.bool(forKey: PreferenceKey.showTime.rawValue)
  }

  ///  True if the user wants a notification at five percent.
  var fivePercentNotification: Bool {
    return userDefaults.bool(forKey: PreferenceKey.fivePercentNotification.rawValue)
  }

  ///  True if the user wants a notification at ten percent.
  var tenPercentNotification: Bool {
    return userDefaults.bool(forKey: PreferenceKey.tenPercentNotification.rawValue)
  }

  ///  True if the user wants a notification at fifeteen percent.
  var fifeteenPercentNotification: Bool {
    return userDefaults.bool(forKey: PreferenceKey.fifeteenPercentNotification.rawValue)
  }

  ///  True if the user wants a notification at twenty percent.
  var twentyPercentNotification: Bool {
    return userDefaults.bool(forKey: PreferenceKey.twentyPercentNotification.rawValue)
  }

  ///  True if the user wants a notification at hundred percent.
  var hundredPercentNotification: Bool {
    return userDefaults.bool(forKey: PreferenceKey.hundredPercentNotification.rawValue)
  }

  ///  Keeps the percentage the user was last notified.
  var lastNotified: NotificationKey? {
    get {
      return NotificationKey(rawValue: userDefaults.integer(forKey: PreferenceKey.lastNotification.rawValue))
    }
    set {
      guard let notificationKey = newValue else {
        return
      }
      userDefaults.set(notificationKey.rawValue, forKey: PreferenceKey.lastNotification.rawValue)
    }
  }

  /// A set of all percentages where the user is interested.
  var notifications: Set<NotificationKey> {
    // Create an empty set.
    var result: Set<NotificationKey> = []
    // Check the users notification settings and
    // add enabled notifications to the result set.
    if fivePercentNotification {
      result.insert(.fivePercent)
    }
    if tenPercentNotification {
      result.insert(.tenPercent)
    }
    if fifeteenPercentNotification {
      result.insert(.fifeteenPercent)
    }
    if twentyPercentNotification {
      result.insert(.twentyPercent)
    }
    if hundredPercentNotification {
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
  fileprivate func registerUserDefaults() {
    let defaultPreferences = [PreferenceKey.showTime.rawValue : false,
                              PreferenceKey.fivePercentNotification.rawValue : false,
                              PreferenceKey.tenPercentNotification.rawValue : false,
                              PreferenceKey.fifeteenPercentNotification.rawValue : true,
                              PreferenceKey.twentyPercentNotification.rawValue : false,
                              PreferenceKey.hundredPercentNotification.rawValue : true,
                              PreferenceKey.lastNotification.rawValue : 0] as [String : Any]

    userDefaults.register(defaults: defaultPreferences)
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
enum PreferenceKey: String {
  case showTime                    = "ShowTimePref"
  case fivePercentNotification     = "FivePercentNotificationPref"
  case tenPercentNotification      = "TenPercentNotificationPref"
  case fifeteenPercentNotification = "FifeteenPercentNotificationPref"
  case twentyPercentNotification   = "TwentyPercentNotificationPref"
  case hundredPercentNotification  = "HundredPercentNotificationPref"
  case lastNotification            = "LastNotifiedPref"
}
