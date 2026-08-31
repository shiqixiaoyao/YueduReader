import Foundation
import SwiftData

@Model
final class BookSource {
    var name: String
    var baseURL: String
    var searchURL: String
    var enabled: Bool
    var updatedAt: Date

    init(name: String, baseURL: String, searchURL: String = "", enabled: Bool = true) {
        self.name = name; self.baseURL = baseURL; self.searchURL = searchURL; self.enabled = enabled; self.updatedAt = .now
    }
}
