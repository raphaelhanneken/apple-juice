//
// WidgetPreview.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import SwiftUI
import WidgetKit

struct AppleJuiceWidget_Previews: PreviewProvider {
    static var previews: some View {
        AppleJuiceWidgetEntryView(entry: BatteryEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
