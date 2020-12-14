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
        let battery: BatteryService?
        do {
            battery = try BatteryService()
        } catch {
            battery = nil
        }

        guard let percentage = battery?.percentage,
              let timeRemaining = battery?.timeRemaining,
              let health = battery?.health,
              let powerUsage = battery?.powerUsage,
              let amperage = battery?.amperage,
              let currentCharge = battery?.charge,
              let capacity = battery?.capacity,
              let powerSource = battery?.powerSource,
              let cycleCount = battery?.cycleCount
        else {
            return
        }

        let entries = [
            DataRow(title: powerSource.localizedDescription,
                    value: "\(percentage.formatted) \(timeRemaining.formatted)"),
            DataRow(title: NSLocalizedString("Charge", comment: ""),
                    value: "\(currentCharge) / \(capacity) mAh (\(amperage) mA)"),
            DataRow(title: NSLocalizedString("Power Usage", comment: ""),
                    value: "\(powerUsage) Watts"),
            DataRow(title: NSLocalizedString("Health", comment: ""),
                    value: "\(health) (\(cycleCount) Ladezyklen)"),
        ]
        let entry = WidgetData(date: Date(), rows: entries)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetData>) -> Void) {
        var entries: [WidgetData] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset * 10, to: currentDate)!
            let entry = WidgetData(date: entryDate, rows: [])
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
