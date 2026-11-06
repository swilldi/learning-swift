//
//  TaskRow.swift
//  Focusly
//
//  Created by Dmitriy on 05.11.2026.
//

import FocuslyCore
import SwiftUI

struct TaskRow: View {
    @Binding var task: FocusTask

    var body: some View {
        HStack {
            Toggle("Выполнено", isOn: $task.isDone)
                .labelsHidden()
            Text(task.title)
                .strikethrough(task.isDone)
            Spacer()
            Text("\(task.completedPomodoros)/\(task.estimate) 🍅")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview(".constant") {
    TaskRow(task: .constant(FocusTask(title: "A")))
}

#Preview("@Previewable") {
    @Previewable @State var task = FocusTask(
        title: "A"
    )

    TaskRow(task: $task)
}
