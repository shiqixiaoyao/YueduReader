import Foundation

enum BookSourceFileParser {
    static func parse(data: Data) throws -> [BookSource] {
        let object = try JSONSerialization.jsonObject(with: data)
        let items = (object as? [[String: Any]]) ?? (object as? [String: Any]).map { [$0] } ?? []
        return items.compactMap { makeSource(from: $0) }
    }
    static func makeSource(from item: [String: Any]) -> BookSource? {
        let name = (item["bookSourceName"] as? String) ?? (item["name"] as? String) ?? (item["title"] as? String) ?? "未命名书源"
        let search = (item["searchUrl"] as? String) ?? (item["searchURL"] as? String) ?? (((item["ruleSearch"] as? [String: Any])?["searchUrl"] as? String) ?? "")
        var base = (item["bookSourceUrl"] as? String) ?? (item["baseURL"] as? String) ?? (item["baseUrl"] as? String) ?? (item["url"] as? String) ?? ""
        if base.isEmpty, let u = URL(string: search), let scheme = u.scheme, let host = u.host { base = "\(scheme)://\(host)" }
        guard !base.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let enabled = (item["enabled"] as? Bool) ?? ((item["enabled"] as? Int).map { $0 != 0 } ?? true)
        let raw = (try? JSONSerialization.data(withJSONObject: item)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        return BookSource(name: name.trimmingCharacters(in: .whitespacesAndNewlines), baseURL: base, searchURL: search, enabled: enabled, rawJSON: raw)
    }
}
