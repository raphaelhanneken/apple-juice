//
// StatusIcon.swift
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

import Cocoa

/// A battery status bar item.
final class BatteryStatusBarItem: NSObject {

    /// The applications status bar item.
    private let item: NSStatusItem!

    /// The icon to display in the battery status bar item.
    private var icon = StatusIcon()

    /// The status bar items button.
    var button: NSButton? {
        return item.button
    }

    // MARK: - Methods

    /// Instantiate a new battery status bar item.
    ///
    /// - Parameters:
    ///   - target: The target that implements the supplied action.
    ///   - action: The action to be triggered, when the
    ///             user clicks the status bar item.
    init(withTarget target: AnyObject?, andAction action: Selector?) {
        // Find a place to live.
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // Set Properties.
        item.target = target
        item.action = action

        // Initialize super class
        super.init()
    }

    /// Instantiate a new battery status bar item, in case of an error.
    ///
    /// - Parameters:
    ///   - error: The error that occured.
    ///   - target: The target that implements the supplied action.
    ///   - action: The action to be triggered, when the 
    ///             user clicks the status bar item.
    convenience init(forError error: BatteryError?, withTarget target: AnyObject?, andAction action: Selector?) {
        self.init(withTarget: target, andAction: action)

        guard let btn = item.button else {
            return
        }
        btn.image = icon.drawBatteryImage(forError: error)
    }

    /// Initialize a battery status bar item.
    override convenience init() {
        self.init(withTarget: nil, andAction: nil)
    }

    /// Update the status bar item.
    ///
    /// - Parameter battery: The battery object, with new information.
    func update(batteryInfo battery: Battery?) {
        guard
            let button        = item.button,
            let batteryState  = battery?.state,
            let timeRemaining = battery?.timeRemainingFormatted else {
                return
        }
        // Set the attributed status bar item title.
        button.attributedTitle = title(withPercentage: batteryState.percentage,
                                       andTime: timeRemaining)
        // Draw the corresponding status bar image.
        button.image = icon.drawBatteryImage(forStatus: batteryState)
        // Set the image position relative to it's title.
        button.imagePosition = .imageRight
    }

    /// Display the supplied menu when the user clicks on
    /// the status bar item.
    ///
    /// - Parameter menu: The menu to display the user.
    func popUpMenu(_ menu: NSMenu) {
        item.popUpMenu(menu)
    }

    // MARK: - Private

    ///  Creates an attributed string for the status bar item's title.
    ///
    ///  - parameter percent: The battery's current charging state.
    ///  - parameter time:    The estimated remaining time in a human readable format.
    ///  - returns:           The attributed title with percentage or time information, respectively.
    private func title(withPercentage percent: Int, andTime time: String) -> NSAttributedString {
        // Define some attributes to make the status bar item look more like Apple's battery gauge.
        let attrs = [NSAttributedStringKey.font: NSFont.menuBarFont(ofSize: 12.0)]
        // Check whether the user wants to see the remaining time or not.
        if UserPreferences.showTime {
            return NSAttributedString(string: "\(time) ", attributes: attrs)
        } else {
            return NSAttributedString(string: "\(percent) % ", attributes: attrs)
        }
    }

}
