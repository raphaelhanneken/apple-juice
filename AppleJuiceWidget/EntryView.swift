//
// EntryView.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import SwiftUI
import WidgetKit

struct WidgetData: TimelineEntry {
    let date: Date
    let rows: [DataRow]

    var timestamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .none
        dateFormatter.locale = Locale.current

        return dateFormatter.string(from: date)
    }
}

struct DataRow: Identifiable {
    let id: UUID = UUID()
    let title: String
    let value: String
}

struct AppleJuiceWidgetEntryView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            ForEach(entry.rows) { row in
                HStack {
                    Text(row.title).bold()
                    Spacer()
                    Text(row.value)
                }
                Divider()
            }
            Text(entry.timestamp)
        }
        .padding(.all)
    }
}
