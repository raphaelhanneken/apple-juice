//
// AppleJuiceWidget.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import WidgetKit
import SwiftUI

@main
struct AppleJuiceWidget: Widget {
    let kind: String = "AppleJuiceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AppleJuiceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Apple Juice Widget")
        .description("Additional battery information.")
        .supportedFamilies([.systemMedium])
    }
}
