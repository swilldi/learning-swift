//
//  TaskRow.swift
//  Focusly
//
//  Created by Dmitriy on 05.11.2026.
//

import FocuslyCore
import SwiftUI

struct TaskRow: View {
    let task: FocusTask
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isDone ? "checkbox.circle.fill" : "circle")
            }
            Text(task.title)
                .strikethrough(task.isDone)
            Spacer()
            Text("\(task.completedPomodoros)/\(task.estimate) 🍅")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    var task = FocusTask(title: "A")

    TaskRow(task: task, onToggle: { task.isDone.toggle() })
}
