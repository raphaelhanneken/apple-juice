//
// Provider.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetData {
        WidgetData(date: Date(), rows: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetData) -> Void) {
        completion(WidgetData(date: Date(), rows: getBatteryData()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetData>) -> Void) {
        var entries: [WidgetData] = []
        entries.append(WidgetData(date: Date(), rows: getBatteryData()))
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

    private func getBatteryData() -> [DataRow] {
        let battery: BatteryService!
        do {
            battery = try BatteryService()
        } catch {
            return []
        }

        guard let health = battery.health,
              let powerUsage = battery.powerUsage,
              let amperage = battery.amperage,
              let currentCharge = battery.charge,
              let capacity = battery.capacity,
              let cycleCount = battery.cycleCount
        else {
            return []
        }

        return [
            DataRow(title: battery.powerSource.localizedDescription,
                    value: "\(battery.percentage.formatted) \(battery.timeRemaining.formatted)"),
            DataRow(title: NSLocalizedString("Charge", comment: ""),
                    value: "\(currentCharge) / \(capacity) mAh (\(amperage) mA)"),
            DataRow(title: NSLocalizedString("Power Usage", comment: ""),
                    value: "\(powerUsage) Watts"),
            DataRow(title: NSLocalizedString("Health", comment: ""),
                    value: "\(health) (\(cycleCount) Ladezyklen)"),
        ]
    }
}
