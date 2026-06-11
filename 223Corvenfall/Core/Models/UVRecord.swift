import Foundation

struct UVRecord: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var maxIndex: Float
    var exposureDuration: Int

    init(id: UUID = UUID(), date: Date, maxIndex: Float, exposureDuration: Int) {
        self.id = id
        self.date = date
        self.maxIndex = maxIndex
        self.exposureDuration = exposureDuration
    }
}
