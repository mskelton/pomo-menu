import Foundation

enum StatusType: String, Codable {
    case Idle, Focus, Break
}

struct Status: Codable {
    let type: StatusType
    let start: Date
    let end: Date
    let lastNotified: Date?
}
