import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var didLoadDefaults = false

    var body: some View {
        TabView {
            BookshelfView().tabItem { Label("书架", systemImage: "books.vertical") }
            LibraryView().tabItem { Label("书城", systemImage: "building.columns") }
            SettingsView().tabItem { Label("设置", systemImage: "gearshape") }
        }
        .tint(.accentColor)
        .task {
            guard !didLoadDefaults else { return }
            didLoadDefaults = true
            loadDefaultSourcesIfNeeded(context: modelContext)
        }
    }

    private func loadDefaultSourcesIfNeeded(context: ModelContext) {
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
