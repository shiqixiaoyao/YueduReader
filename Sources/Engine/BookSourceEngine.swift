import Foundation
import SwiftSoup

struct BookSearchResult: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let author: String
    let url: String
    init(title: String, author: String, url: String) { self.title = title; self.author = author; self.url = url }
}

enum BookSourceEngine {
    static func search(query: String, source: BookSource) async throws -> [BookSearchResult] {
        var template = source.searchURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !template.isEmpty else { return [] }
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        template = template.replacingOccurrences(of: "{{key}}", with: encoded).replacingOccurrences(of: "{key}", with: encoded).replacingOccurrences(of: "%s", with: encoded)
        if template.hasPrefix("/") { template = source.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + template }
        let html = try await NetworkManager.shared.fetch(urlString: template)
        let document = try SwiftSoup.parse(html)
        let selectors = [".item", ".book", ".result", "li", "article", "h2", "h3"]
        var output: [BookSearchResult] = []
        for selector in selectors {
            for element in try document.select(selector) {
                let link = try element.select("a").first()
                let title = try (link?.text() ?? element.text()).trimmingCharacters(in: .whitespacesAndNewlines)
                let href = try link?.attr("href") ?? ""
                guard title.count >= 2, !href.isEmpty, !output.contains(where: { $0.title == title && $0.url == href }) else { continue }
                output.append(BookSearchResult(title: title, author: "", url: href))
            }
            if !output.isEmpty { break }
        }
        return output
    }
}
