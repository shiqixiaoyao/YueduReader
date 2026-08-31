import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Foundation

struct SourceManagerView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query(sort: [SortDescriptor(\BookSource.name)]) private var sources: [BookSource]
    @State private var showingAddSource = false
    @State private var showingFileImporter = false
    @State private var importMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button { restoreBuiltInSources() } label: { Label("恢复默认内置书源", systemImage: "arrow.clockwise") }
                    Button { showingFileImporter = true } label: { Label("从本地文件导入", systemImage: "doc.badge.plus") }
                    Button { showingAddSource = true } label: { Label("手动添加书源", systemImage: "plus.circle") }
                } header: { Text("书源管理") } footer: { Text("恢复内置书源会按名称和地址去重。") }
                if sources.isEmpty {
                    ContentUnavailableView("暂无书源", systemImage: "server.rack", description: Text("添加一个书源后即可搜索书籍。"))
                } else {
                    Section("已添加的书源") {
                        ForEach(sources) { source in
                            Toggle(source.name, isOn: Binding(get: { source.enabled }, set: { source.enabled = $0 }))
                        }.onDelete { offsets in
                            for offset in offsets { modelContext.delete(sources[offset]) }
                            try? modelContext.save()
                        }
                    }
                }
            }
            .navigationTitle("书源管理")
            .sheet(isPresented: $showingAddSource) { AddSourceView() }
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.json, .plainText, .data], allowsMultipleSelection: true) { result in importSources(from: result) }
            .alert("书源管理", isPresented: Binding(get: { importMessage != nil }, set: { if !$0 { importMessage = nil } })) { Button("确定") { importMessage = nil } } message: { Text(importMessage ?? "") }
        }
    }

    private func restoreBuiltInSources() {
        guard let url = Bundle.main.url(forResource: "DefaultSources", withExtension: "json"), let data = try? Data(contentsOf: url) else { importMessage = "找不到内置书源文件。"; return }
        do {
            let items = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            var added = 0
            for item in items {
                let name = item["bookSourceName"] as? String ?? "未命名书源"
                let base = item["bookSourceUrl"] as? String ?? ""
                guard !base.isEmpty else { continue }
                let duplicate = sources.contains { $0.name == name || $0.baseURL == base }
                if !duplicate {
                    let raw = (try? JSONSerialization.data(withJSONObject: item)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
                    modelContext.insert(BookSource(name: name, baseURL: base, searchURL: item["searchUrl"] as? String ?? "", rawJSON: raw)); added += 1
                }
            }
            try modelContext.save(); importMessage = "已恢复内置书源：新增 \(added) 个。"
        } catch { importMessage = "恢复失败：\(error.localizedDescription)" }
    }

    private func importSources(from result: Result<[URL], Error>) {
        do {
            var count = 0
            for url in try result.get() { let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }; for source in try BookSourceFileParser.parse(data: Data(contentsOf: url)) { modelContext.insert(source); count += 1 } }
            try modelContext.save(); importMessage = "已成功导入 \(count) 个书源。"
        } catch { importMessage = "导入失败：\(error.localizedDescription)" }
    }
}

private enum BookSourceFileParser {
    static func parse(data: Data) throws -> [BookSource] {
        let object = try JSONSerialization.jsonObject(with: data)
        let items = (object as? [[String: Any]]) ?? (object as? [String: Any]).map { [$0] } ?? []
        return items.compactMap { item in
            let name = item["bookSourceName"] as? String ?? item["name"] as? String ?? "未命名书源"
            let base = item["bookSourceUrl"] as? String ?? item["baseURL"] as? String ?? item["url"] as? String ?? ""
            guard !base.isEmpty else { return nil }
            return BookSource(name: name, baseURL: base, searchURL: item["searchUrl"] as? String ?? "", enabled: item["enabled"] as? Bool ?? true)
        }
    }
}
