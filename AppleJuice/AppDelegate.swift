//
// AppDelegate.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        UserPreferences.registerDefaults()
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }

    // Post messages to the user notification center.
    func userNotificationCenter(_: NSUserNotificationCenter,
                                shouldPresentNotification _: NSUserNotification) -> Bool
    {
        true
    }
}
