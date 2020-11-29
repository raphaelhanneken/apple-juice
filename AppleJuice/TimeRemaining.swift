//
//  TimeRemaining.swift
//  Apple Juice
//
//  Created by Raphael Hanneken on 29.11.20.
//  Copyright © 2020 Raphael Hanneken. All rights reserved.
//

import Foundation

struct TimeRemaining {
    let minutes: Int?
    let state: BatteryState?

    var formatted: String {
        guard let minutesRemaining = minutes, let batteryState = state else {
            return NSLocalizedString("Calculating", comment: "")
        }

        if batteryState == .chargedAndPlugged {
            return NSLocalizedString("Charged Notification Title", comment: "")
        }

        return String(format: "%dh %02dm", arguments: [minutesRemaining / 60, minutesRemaining % 60])
    }
}
