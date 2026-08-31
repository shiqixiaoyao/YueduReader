import SwiftUI
import SwiftData

@main
struct YueduReaderApp: App {
    var body: some Scene {
        WindowGroup { MainTabView() }
            .modelContainer(for: [Book.self, BookSource.self, Chapter.self])
    }
}

extension MainTabView {
    func loadDefaultSourcesIfNeeded(context: ModelContext) {
        var descriptor = FetchDescriptor<BookSource>()
        descriptor.fetchLimit = 1
        guard (try? context.fetch(descriptor).isEmpty) == true,
              let url = Bundle.main.url(forResource: "DefaultSources", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }
        for item in items {
            let name = item["bookSourceName"] as? String ?? "未命名书源"
            let base = item["bookSourceUrl"] as? String ?? ""
            let search = item["searchUrl"] as? String ?? ""
            guard !base.isEmpty else { continue }
            let raw = (try? JSONSerialization.data(withJSONObject: item)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
            context.insert(BookSource(name: name, baseURL: base, searchURL: search, rawJSON: raw))
        }
        try? context.save()
    }
}
