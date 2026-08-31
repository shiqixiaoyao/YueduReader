import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: [SortDescriptor(\BookSource.name)]) private var sources: [BookSource]
    @State private var searchText = ""
    @State private var results: [BookSearchResult] = []
    @State private var isSearching = false
    @State private var status = ""

    private var enabledSources: [BookSource] { sources.filter { $0.enabled } }

    var body: some View {
        NavigationStack {
            List {
                Section("启用的书源（\(enabledSources.count)）") {
                    if enabledSources.isEmpty { Text("暂无启用书源，请在设置 → 书源管理中恢复或添加。\").foregroundStyle(.secondary) }
                    ForEach(enabledSources) { source in
                        Label(source.name, systemImage: "server.rack")
                            .lineLimit(1)
                    }
                }
                if isSearching { Section { ProgressView("正在搜索 \(enabledSources.count) 个书源…") } }
                if !status.isEmpty { Section { Text(status).foregroundStyle(.secondary) } }
                if !results.isEmpty {
                    Section("搜索结果（\(results.count)）") {
                        ForEach(results) { result in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.title).font(.headline)
                                Text(result.author.isEmpty ? result.url : result.author).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                    }
                }
            }
            .navigationTitle("书城")
            .searchable(text: $searchText, prompt: "搜索书名或作者")
            .onSubmit(of: .search) { Task { await search() } }
        }
    }

    private func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { results = []; status = ""; return }
        isSearching = true; status = ""
        var collected: [BookSearchResult] = []
        var failures = 0
        await withTaskGroup(of: [BookSearchResult].self) { group in
            for source in enabledSources { group.addTask { (try? await BookSourceEngine.search(query: query, source: source)) ?? [] } }
            for await values in group { collected.append(contentsOf: values) }
        }
        isSearching = false
        results = Array(collected.prefix(100))
        if results.isEmpty { status = enabledSources.isEmpty ? "没有启用的书源。" : "未找到结果；部分网站可能需要更新书源规则或暂时不可访问。" }
    }
}
