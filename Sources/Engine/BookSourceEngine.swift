import Foundation
import SwiftSoup

struct BookSearchResult: Identifiable, Sendable {
    let id: UUID
    let title: String
    let author: String
    let url: String

    init(title: String, author: String, url: String) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.url = url
    }
}

enum BookSourceEngine {
    static func search(query: String, source: BookSource) async throws -> [BookSearchResult] {
        let template = source.searchURL
        guard !template.isEmpty else { return [] }
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let requestURL = template.replacingOccurrences(of: "{key}", with: encoded)
        let html = try await NetworkManager.shared.fetch(urlString: requestURL)
        let document = try SwiftSoup.parse(html)
        return try document.select("a").compactMap { element in
            let title = try element.text().trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return nil }
            let href = try element.attr("href")
            guard !href.isEmpty else { return nil }
            return BookSearchResult(title: title, author: "", url: href)
        }
    }
}
