//
// NotificationSubmenu.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation
import AppKit

class NotificationSubmenu {
    public func update(mainMenu : NSMenu?) {
        guard let notifSubmenu = mainMenu?.item(at: 2)?.submenu else {
            return
        }
        
        while notifSubmenu.item(at: 0)?.identifier?.rawValue != "separator" {
            notifSubmenu.removeItem(at: 0)
        }
        guard let addNotifMenuItem = notifSubmenu.item(at: 1) else {
            return
        }
        addNotifMenuItem.action = #selector(NotificationSubmenu.addNotif(menuItem:))
        addNotifMenuItem.target = self
        
        for p in UserPreferences.percentagesNotification.reversed() {
            let perMenuItem = NSMenuItem(title: Percentage(numeric: p).formatted,
                                         action: #selector(NotificationSubmenu.removeNotif(menuItem:)),
                                         keyEquivalent: "")
            perMenuItem.state = .on
            perMenuItem.target = self
            perMenuItem.identifier = NSUserInterfaceItemIdentifier(String(p))
            notifSubmenu.insertItem(perMenuItem, at: 0)
        }
    }
    
    @objc public func removeNotif(menuItem: NSMenuItem) {
        UserPreferences.removeNotif(p: Int(menuItem.identifier?.rawValue ?? "-1") ?? -1)
    }
    
    @objc public func addNotif(menuItem: NSMenuItem) {
        return
    }
    
}
