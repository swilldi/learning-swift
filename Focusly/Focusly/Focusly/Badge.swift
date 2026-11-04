//
//  Badge.swift
//  Focusly
//
//  Created by Dmitriy on 04.11.2026.
//

import SwiftUI

struct Badge: View {
    let text: String
    var body: some View {
        Text(text)
            .padding()
            .background(.green)
            .clipShape(.capsule)
    }
}

#Preview {
    Badge(text: "текст для проверки")
}
