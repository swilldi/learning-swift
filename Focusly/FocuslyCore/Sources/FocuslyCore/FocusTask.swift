//
//  FocusTask.swift
//  FocuslyCore
//
//  Created by Dmitriy on 04.11.2026.
//

import Foundation

public struct FocusTask: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var title: String
    public var notes: String
    public var isDone: Bool
    public let createdAt: Date
    public var estimate: Int {
        didSet { estimate = max(1, estimate) }
    }
    public private(set) var completedPomodoros: Int

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        isDone: Bool = false,
        createdAt: Date = .now,
        estimate: Int = 1
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.notes = notes
        self.isDone = isDone
        self.createdAt = createdAt
        self.estimate = max(1, estimate)
        self.completedPomodoros = 0
    }

    public var progress: Double {
        min(1, Double(completedPomodoros) / Double(estimate))
    }

    public var isOverEstimate: Bool {
        completedPomodoros > estimate
    }

    public mutating func registerPomodoro() {
        completedPomodoros += 1
    }
}
