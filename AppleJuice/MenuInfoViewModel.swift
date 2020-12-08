//
// MenuInfoViewModel.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

@available(OSX 11.0, *)
class MenuInfoViewModel: ObservableObject {
    @Published var powerSource = NSLocalizedString("Unknown", comment: "")
    @Published var remaining = NSLocalizedString("Calculating", comment: "")
    @Published var currentCharge = "--"

    private let batteryService: BatteryService?

    init() {
        do {
            batteryService = try BatteryService()
        } catch {
            batteryService = nil
        }

        update()

    NotificationCenter.default
            .addObserver(self,
                         selector: #selector(MenuInfoViewModel.powerSourceChanged(_:)),
                         name: NSNotification.Name(rawValue: powerSourceChangedNotification),
                         object: nil)
    }

    @objc public func powerSourceChanged(_: AnyObject) {
        update()
    }

    private func update() {
        guard let percentage = batteryService?.percentage,
              let timeRemaining = batteryService?.timeRemaining,
              let currentCharge = batteryService?.charge,
              let maxCapacity = batteryService?.capacity,
              let amperage = batteryService?.amperage,
              let powerSource = batteryService?.powerSource
        else {
            return
        }

        self.powerSource = powerSource.localizedDescription
        self.currentCharge = String(format: "%i / %i mAh (%i mA)", currentCharge, maxCapacity, amperage)
        if UserPreferences.showTime {
            self.remaining = percentage.formatted
        } else {
            self.remaining = timeRemaining.formatted
        }
    }
}
