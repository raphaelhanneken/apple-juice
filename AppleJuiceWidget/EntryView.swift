//
// EntryView.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import SwiftUI
import WidgetKit

struct BatteryEntry: TimelineEntry {
    let date: Date
}

struct AppleJuiceWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        HStack {
            Text("Row Title")
            Spacer()
            Text(entry.date, style: .time)
        }
        .padding(.all)
    }
}
