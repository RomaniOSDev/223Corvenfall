import Foundation

struct UVHistoryEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var day: Date
    var uvLevel: Int

    init(id: UUID = UUID(), day: Date, uvLevel: Int) {
        self.id = id
        self.day = day
        self.uvLevel = uvLevel
    }
}
