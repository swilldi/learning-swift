//
//  TaskListView.swift
//  Focusly
//
//  Created by Dmitriy Dudyrev on 06.11.2026.
//

import SwiftUI
import FocuslyCore

struct TaskListView: View {
    @State private var taskList = TaskListViewModel()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Новая задача", text: $taskList.newTaskTitle)
                    .onSubmit(taskList.addTask)
                Button("Добавить", systemImage: "plus", action: taskList.addTask)
                    .disabled(!taskList.canAddTask)
            }
            
            List(taskList.tasks) { task in
                TaskRow(task: task, onToggle: { taskList.toggleDone(task.id) })
                    .contextMenu {
                        Button("Удалить") { taskList.deleteTask(task.id) }
                    }
            }
        }
    }
}

#Preview {
    TaskListView()
}
