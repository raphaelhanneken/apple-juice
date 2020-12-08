//
// MenuInfoView.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import SwiftUI

@available(OSX 11.0, *)
struct MenuInfoView: View {
    @StateObject private var model = MenuInfoViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                Text(model.powerSource)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.bottom, 3)
            HStack(alignment: .top, spacing: 9) {
                Text(model.remaining)
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                Text(model.currentCharge)
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 15)
    }
}
