//
// MenuLocalization.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation
import AppKit

protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

// Allow menu items to use localizable strings as titles
extension NSMenuItem: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            attributedTitle = NSAttributedString(string: key?.localized ?? "Could not translate");
        }
    }
}
