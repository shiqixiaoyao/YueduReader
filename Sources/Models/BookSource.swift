import Foundation
import SwiftData

@Model
final class BookSource {
    var name: String
    var baseURL: String
    var searchURL: String
    var enabled: Bool
    var updatedAt: Date
    var rawJSON: String

    init(name: String, baseURL: String, searchURL: String = "", enabled: Bool = true, rawJSON: String = "") {
        self.name = name; self.baseURL = baseURL; self.searchURL = searchURL; self.enabled = enabled; self.updatedAt = .now; self.rawJSON = rawJSON
    }
}
