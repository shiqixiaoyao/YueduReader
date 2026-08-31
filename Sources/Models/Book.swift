import Foundation
import SwiftData

@Model
final class Book {
    var title: String
    var author: String
    var coverURL: String
    var sourceName: String
    var lastReadChapter: Int
    var lastReadAt: Date?
    @Relationship(deleteRule: .cascade, inverse: \Chapter.book) var chapters: [Chapter] = []

    init(title: String, author: String = "", coverURL: String = "", sourceName: String = "") {
        self.title = title; self.author = author; self.coverURL = coverURL; self.sourceName = sourceName
        self.lastReadChapter = 0
    }
}
