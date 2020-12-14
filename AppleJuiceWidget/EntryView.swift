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
                    Text(row.title)
                    Spacer()
                    Text(row.value)
                }
                .padding(.bottom, 2.0)

                Divider()
            }
        }
        .padding(.all)
    }
}
