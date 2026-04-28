import Foundation

struct Note: Identifiable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date
}
