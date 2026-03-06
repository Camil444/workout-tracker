import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var name: String
    var iconName: String
    var createdAt: Date
    var sortOrder: Int
    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout)
    var exercises: [Exercise]

    init(
        name: String,
        iconName: String = "bolt.fill",
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.createdAt = Date()
        self.sortOrder = sortOrder
        self.exercises = []
    }
}
