import Foundation
import Observation

@MainActor
@Observable
public final class TaskListViewModel {
    public private(set) var tasks: [FocusTask]
    public var newTaskTitle: String = ""
    
    public init(tasks: [FocusTask] = []) {
        self.tasks = tasks
    }
    
    public var canAddTask: Bool {
        !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public func addTask() {
        guard canAddTask else { return }
        tasks.append(FocusTask(title: newTaskTitle))
        newTaskTitle = ""
    }
    
    public func deleteTask(_ id: UUID) {
        tasks.removeAll { $0.id == id }
    }
    
    public func toggleDone(_ id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isDone.toggle()
    }
    
}
