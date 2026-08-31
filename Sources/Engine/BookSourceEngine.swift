import Foundation
import SwiftSoup

struct BookSearchResult: Identifiable, Sendable {
    let id = UUID(); let title: String; let author: String; let url: String
}

enum BookSourceEngine {
    static func search(query: String, source: BookSource) async throws -> [BookSearchResult] {
        guard !source.searchURL.isEmpty else { return [] }
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let html = try await NetworkManager.shared.fetch(urlString: source.searchURL.replacingOccurrences(of: "{key}", with: encoded))
        let document = try SwiftSoup.parse(html)
        return try document.select("a").compactMap { element in
            let title = try element.text().trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty, let href = try? element.attr("href"), !href.isEmpty else { return nil }
            return BookSearchResult(title: title, author: "", url: href)
        }
    }
}
