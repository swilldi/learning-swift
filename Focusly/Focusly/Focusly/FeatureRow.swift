//
//  FeatureRow.swift
//  Focusly
//
//  Created by Dmitriy on 04.11.2026.
//

import SwiftUI

struct FeatureRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    FeatureRow(title: "F1", systemImage: "flag.pattern.checkered")
}
