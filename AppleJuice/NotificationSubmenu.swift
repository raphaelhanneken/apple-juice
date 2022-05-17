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
        guard let addNotifSubmenu = notifSubmenu.item(at: 1)?.submenu else {
            return
        }
        while addNotifSubmenu.numberOfItems > 0 {
            addNotifSubmenu.removeItem(at: 0)
        }
        for i in 1..<21 {
            let p = 5*(21-i)
            let existingNotif = UserPreferences.percentagesNotification.contains(p)
            let perMenuItem = NSMenuItem(title: Percentage(numeric: p).formatted,
                                         action: existingNotif ? #selector(NotificationSubmenu.removeNotif(menuItem:)) : #selector(NotificationSubmenu.addNotif(menuItem:)),
                                         keyEquivalent: "")
            perMenuItem.state = existingNotif ? .on : .off
            perMenuItem.target = self
            perMenuItem.identifier = NSUserInterfaceItemIdentifier(String(p))
            if existingNotif {
                notifSubmenu.insertItem(perMenuItem, at: 0)
            } else {
                addNotifSubmenu.insertItem(perMenuItem, at: 0)
            }
        }
    }
    
    @objc public func removeNotif(menuItem: NSMenuItem) {
        UserPreferences.removeNotif(p: Int(menuItem.identifier?.rawValue ?? "-1") ?? -1)
    }
    
    @objc public func addNotif(menuItem: NSMenuItem) {
        UserPreferences.addNotif(p: Int(menuItem.identifier?.rawValue ?? "-1") ?? -1)
    }
    
}
