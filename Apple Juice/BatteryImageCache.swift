//
// BatteryImageCache.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Cocoa

///  Caches a drawn battery image for a certain battery status.
struct BatteryImageCache {
    ///  Holds the drawn battery image.
    let image: NSImage?
    ///  Holds the corresponding battery status for the image.
    let batteryStatus: BatteryState

    /// Initializes a new BatteryImageCache.
    ///
    /// - parameter status: The BatteryStatusType corresponding to the battery image.
    /// - parameter img:    The drawn battery image.
    /// - returns:          A new BatteryImageCache.
    init(forStatus status: BatteryState, withImage img: NSImage?) {
        batteryStatus = status
        image = img
    }
}
