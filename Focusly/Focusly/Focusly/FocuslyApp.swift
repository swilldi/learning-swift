//
//  FocuslyApp.swift
//  Focusly
//
//  Created by Dmitriy on 04.11.2026.
//

import SwiftUI

@main
struct FocuslyApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListDraftView()
        }
        .defaultSize(width: 900, height: 600)

    }
}
