//
//  TaskListDraftView.swift
//  Focusly
//
//  Created by Dmitriy on 05.11.2026.
//

import FocuslyCore
import SwiftUI

struct TaskListDraftView: View {
    @State var tasks = [FocusTask]()
    @State private var newTitle = ""

    var remainingCount: Int {
        tasks.count { !$0.isDone }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Новая задача ", text: $newTitle)
                    .onSubmit(addTask)
                Button("Добавить", systemImage: "plus", action: addTask)
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(8)

            List($tasks) { $task in
                TaskRow(task: $task)
                    .contextMenu {
                        Button("Удалить") {
                            tasks.removeAll { $0.id == task.id }
                        }
                    }
            }

            Text("Осталось \(remainingCount) задач")
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func addTask() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        tasks.append(FocusTask(title: title))
        newTitle = ""
    }
}

#Preview {
    TaskListDraftView(
        tasks: [
            FocusTask(title: "A"),
            FocusTask(title: "B"),
            FocusTask(title: "C"),
            FocusTask(title: "D"),
        ]
    )
}
