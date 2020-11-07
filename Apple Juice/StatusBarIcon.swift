//
// StatusIcon.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa

///  Define the BatteryUIKit path
private let batteryIconPath = "/System/Library/PrivateFrameworks/BatteryUIKit.framework/Versions/A/Resources/"

///  Defines the filenames for Apple's battery images.
///
///  - left: Left-hand side capacity bar cap.
///  - right: Right-hand side capacity bar cap.
///  - middle: Capacity bar filler filename.
///  - empty: Empty battery filename.
///  - chargedAndPlugged: Charged and plugged battery filename.
///  - charging: Charging battery filename.
///  - dead: IOService already open filename.
///  - none: Battery IOService not found filename.
private enum BatteryImage: String {
    case left = "BatteryFillCapLeft"
    case right = "BatteryFillCapRight"
    case middle = "BatteryFill"
    case outline = "BatteryOutline"
    case charging = "Charging"
    case chargedAndPlugged = "ChargedAndPlugged"
    case deadCropped = "DeadCropped"
    case none = "None"
}

///  Draws the status bar image.
struct StatusBarIcon {

    ///  Add a little offset to draw the capacity bar in the correct position.
    private let capacityOffsetX: CGFloat = 1.9
    private let capacityOffsetY: CGFloat = 3.0

    ///  Caches the last drawn battery image.
    private var cache: BatteryImageCache?

    // MARK: - Methods

    ///  Draws a battery image for the supplied BatteryStatusType.
    ///
    ///  - parameter status: The BatteryStatusType, which to draw the image for.
    ///  - returns:          The battery image for the provided battery status.
    mutating func drawBatteryImage(forStatus status: BatteryState) -> NSImage? {
        if let cache = self.cache, cache.batteryStatus == status {
            return cache.image
        }

        switch status {
        case .charging:
            cache = BatteryImageCache(forStatus: status,
                                      withImage: batteryImage(named: .charging))
        case .chargedAndPlugged:
            cache = BatteryImageCache(forStatus: status,
                                      withImage: batteryImage(named: .chargedAndPlugged))
        case let .discharging(percentage):
            cache = BatteryImageCache(forStatus: status,
                                      withImage: dischargingBatteryImage(forPercentage: Double(percentage)))
        }
        return cache?.image
    }

    ///  Draws a battery image according to the provided BatteryError.
    ///
    ///  - parameter err: The BatteryError, which to draw the battery image for.
    ///  - returns:       The battery image for the supplied BatteryError.
    func drawBatteryImage(forError err: BatteryError?) -> NSImage? {
        guard let error = err else {
            return nil
        }
        switch error {
        case .connectionAlreadyOpen:
            return batteryImage(named: .deadCropped)
        case .serviceNotFound:
            return batteryImage(named: .none)
        }
    }

    ///  Draws a battery icon based on the battery's current percentage.
    ///
    ///  - parameter percentage: The current percentage of the battery.
    ///  - returns:              A battery image for the supplied percentage.
    private func dischargingBatteryImage(forPercentage percentage: Double) -> NSImage? {
        guard let batteryEmpty = batteryImage(named: .outline),
            let capacityCapLeft = batteryImage(named: .left),
            let capacityCapRight = batteryImage(named: .right),
            let capacityFill = batteryImage(named: .middle)
        else {
            return nil
        }

        let drawingRect = NSRect(x: capacityOffsetX, y: capacityOffsetY,
                                 width: CGFloat(round(percentage / drawingPrecision)) * capacityFill.size.width,
                                 height: capacityFill.size.height)

        // Draw a special battery icon for low percentages, otherwise drawThreePartImage glitches.
        if drawingRect.width < (2 * capacityFill.size.width) {
            return drawLowPercentageBattryImage()
        }

        drawThreePartImage(withFrame: drawingRect, canvas: batteryEmpty, startCap: capacityCapLeft,
                           fill: capacityFill, endCap: capacityCapRight)

        return batteryEmpty
    }

    /// Draw a special 'low percentage' battery image, since for percentages
    /// this small, the drawThreePartImage method glitches.
    ///
    /// - Returns: A battery image for low percentages.
    private func drawLowPercentageBattryImage() -> NSImage? {
        let img = NSImage(named: "LowBattery")
        img?.isTemplate = true

        return img
    }

    ///  Opens an image file for the supplied image name.
    ///
    ///  - parameter name: The name of the requested image.
    ///  - returns:        The requested image.
    private func batteryImage(named name: BatteryImage) -> NSImage? {
        guard let img = NSImage(named: name.rawValue) else {
            return nil
        }
        img.isTemplate = true

        return img
    }

    ///  Draws a three-part image onto a specified canvas image.
    ///
    ///  - parameter rect:  The rectangle in which to draw the images.
    ///  - parameter img:   The image on which to draw the three-part image.
    ///  - parameter start: The image located on the left end of the frame.
    ///  - parameter fill:  The image used to fill the gap between the start and the end images.
    ///  - parameter end:   The image located on the right end of the frame.
    private func drawThreePartImage(withFrame rect: NSRect, canvas img: NSImage,
                                    startCap start: NSImage, fill: NSImage, endCap end: NSImage) {
        img.lockFocus()
        NSDrawThreePartImage(rect, start, fill, end, false, .copy, 1, false)
        img.unlockFocus()
        img.isTemplate = true
    }
}
