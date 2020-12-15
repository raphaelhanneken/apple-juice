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
}

struct DataRow: Identifiable {
    let id: UUID = UUID()
    let title: String
    let value: String
}

struct AppleJuiceWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            ForEach(entry.rows) { row in
                HStack {
                    Text(row.title).bold()
                    Spacer()
                    Text(row.value)
                }
                Divider()
            }
        }
        .padding(.all)
    }
}
