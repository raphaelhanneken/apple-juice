//
//  AppDelegate.swift
//  Apple Juice
//
//  Created by Raphael Hanneken on 13.01.16.
//  Copyright © 2016 Raphael Hanneken. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }

  // Post messages to the user notification center.
  func userNotificationCenter(center: NSUserNotificationCenter,
    shouldPresentNotification notification: NSUserNotification) -> Bool {
      return true
  }
}
