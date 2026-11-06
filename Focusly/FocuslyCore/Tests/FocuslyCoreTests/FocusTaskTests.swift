import Testing

@testable import FocuslyCore

@Suite("FocusTask")
struct FocusTaskTests {

    @Test func titleIsTrimmed() {
        let task = FocusTask(title: "   Купить молоко  \n \n")
        #expect(task.title == "Купить молоко")
    }

    @Test func progressGrowsWithPomodoros() {
        var task = FocusTask(title: "A", estimate: 4)
        #expect(task.progress == 0.0)
        task.registerPomodoro()
        task.registerPomodoro()
        #expect(task.progress == 0.5)
    }

    @Test func structIsCopiedOnAssignment() {
        let original = FocusTask(title: "A")
        var copy = original
        copy.title = "B"
        #expect(original.title == "A")
    }

    @Test(arguments: [-2, 0]) func estimateToOne(estimate: Int) {
        let task = FocusTask(title: "A", estimate: estimate)
        #expect(task.estimate == 1)
    }

    @Test func progressNotMoreOne() throws {
        var task = FocusTask(title: "A", estimate: 1)
        task.registerPomodoro()
        task.registerPomodoro()
        try #require(task.completedPomodoros > task.estimate)
        #expect(task.progress == 1)
    }

    @Test func completetBelowEstimate() {
        let task = FocusTask(title: "A", estimate: 1)
        #expect(task.isOverEstimate == false)
    }

    @Test func completetEqualEstimate() {
        var task = FocusTask(title: "A", estimate: 1)
        task.registerPomodoro()
        #expect(task.isOverEstimate == false)
    }

    @Test func completetAboveEstimate() {
        var task = FocusTask(title: "A", estimate: 1)
        task.registerPomodoro()
        task.registerPomodoro()
        #expect(task.isOverEstimate)
    }

}
