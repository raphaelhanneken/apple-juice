//
// MenuController.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa
import SwiftUI

class ApplicationMenuDelegate: NSObject, NSMenuDelegate {
    // MARK: Public

    public func menuWillOpen(_ menu: NSMenu) {
        updateBatteryInfoItem(menu.item(at: 0))
    }

    override func awakeFromNib() {
        do {
            batteryService = try BatteryService()
        } catch {
            NSLog(error.localizedDescription)
        }
    }

    // MARK: Private

    private var batteryService: BatteryService!

    private func updateBatteryInfoItem(_ batteryInfoItem: NSMenuItem?) {
        guard let item = batteryInfoItem else {
            return
        }

        item.attributedTitle = getAttributedMenuItemTitle()
        if #available(OSX 11.0, *) {
            let hostingView = NSHostingView(rootView: MenuInfoView())
            hostingView.frame = NSRect(x: 0,
                                       y: 0,
                                       width: hostingView.intrinsicContentSize.width,
                                       height: hostingView.intrinsicContentSize.height)

            item.view = hostingView
        } else {
            item.attributedTitle = getAttributedMenuItemTitle()
        }
    }

    private func getAttributedMenuItemTitle() -> NSAttributedString {
        guard let capacity = batteryService?.capacity,
              let charge = batteryService?.charge,
              let amperage = batteryService?.amperage,
              let percentage = batteryService?.percentage,
              let timeRemaining = batteryService?.timeRemaining,
              let powerSource = batteryService?.powerSource
        else {
            return NSAttributedString(string: NSLocalizedString("Unknown", comment: "Information missing"))
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 3.0

        let remaining = UserPreferences.showTime ? percentage.formatted : timeRemaining.formatted

        let powerSourceLabel = NSMutableAttributedString(
            string: powerSource.localizedDescription,
            attributes: [.font: NSFont.menuFont(ofSize: 13.0), .paragraphStyle: paragraphStyle])

        let details = NSAttributedString(
            string: "\n\(remaining)  \(charge) / \(capacity) mAh (\(amperage) mA)",
            attributes: [.font: NSFont.menuFont(ofSize: 13.0)])

        powerSourceLabel.append(details)

        return powerSourceLabel
    }
}
