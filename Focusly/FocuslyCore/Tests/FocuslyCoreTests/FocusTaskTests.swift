//
//  FocusTaskTest.swift
//  FocuslyCore
//
//  Created by Dmitriy on 04.11.2026.
//

import Testing
@testable import FocuslyCore

@Suite("FocusTasks")
struct FocusTaskTests {

    @Test func titleIsTrimmed() {
        let task = FocusTask(title: "   Купить молоко   ")
        #expect(task.title == "Купить молоко")
    }
    
    @Test func progressGrowsWithPomodoros() {
        var task = FocusTask(title: "Подготовка к БД", estimate: 4)
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
    
}
