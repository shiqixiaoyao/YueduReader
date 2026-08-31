import Foundation
import SwiftData

@Model
final class Chapter {
    var title: String
    var index: Int
    var content: String
    var url: String
    @Relationship(inverse: \Book.chapters)
    var book: Book?

    init(title: String, index: Int, content: String = "", url: String = "", book: Book? = nil) {
        self.title = title
        self.index = index
        self.content = content
        self.url = url
        self.book = book
    }
}
