import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SourceManagerView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query(sort: \BookSource.name) private var sources: [BookSource]
    @State private var showingAddSource = false
    @State private var showingFileImporter = false
    @State private var importMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button { showingFileImporter = true } label: { Label("从本地文件导入", systemImage: "doc.badge.plus") }
                    Button { showingAddSource = true } label: { Label("手动添加书源", systemImage: "plus.circle") }
                } header: { Text("本地导入") } footer: { Text("选择书源 JSON 文件，可一次导入多个书源。") }
                if sources.isEmpty {
                    ContentUnavailableView("暂无书源", systemImage: "server.rack", description: Text("添加一个书源后即可搜索书籍。"))
                } else {
                    Section("已添加的书源") {
                        ForEach(sources) { source in
                            Toggle(source.name, isOn: Binding(get: { source.enabled }, set: { source.enabled = $0 }))
                        }
                        .onDelete { offsets in offsets.map { sources[$0] }.forEach(modelContext.delete); try? modelContext.save() }
                    }
                }
            }
            .navigationTitle("书源管理")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showingAddSource = true } label: { Image(systemName: "plus") } } }
            .sheet(isPresented: $showingAddSource) { AddSourceView() }
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.json], allowsMultipleSelection: true) { importSources(from: $0) }
            .alert("本地导入", isPresented: Binding(get: { importMessage != nil }, set: { if !$0 { importMessage = nil } })) {
                Button("确定") { importMessage = nil }
            } message: { Text(importMessage ?? "") }
        }
    }

    private func importSources(from result: Result<[URL], Error>) {
        do {
            let urls = try result.get(); var imported = 0
            for url in urls {
                let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }
                for item in try BookSourceFileParser.parse(data: Data(contentsOf: url)) { modelContext.insert(item); imported += 1 }
            }
            try modelContext.save()
            importMessage = imported > 0 ? "已成功导入 \(imported) 个书源。" : "文件中没有找到可导入的书源。"
        } catch { importMessage = "导入失败：\(error.localizedDescription)" }
    }
}

private enum BookSourceFileParser {
    static func parse(data: Data) throws -> [BookSource] {
        let object = try JSONSerialization.jsonObject(with: data)
        let dictionaries: [[String: Any]]
        if let array = object as? [[String: Any]] { dictionaries = array }
        else if let dictionary = object as? [String: Any], let nested = dictionary["bookSourceComment"] as? [[String: Any]] { dictionaries = nested }
        else if let dictionary = object as? [String: Any] { dictionaries = [dictionary] }
        else { throw ImportError.invalidFormat }
        return dictionaries.compactMap { item in
            let name = string(item, keys: ["bookSourceName", "name", "sourceName"]) ?? "未命名书源"
            let baseURL = string(item, keys: ["bookSourceUrl", "baseURL", "baseUrl", "url"]) ?? ""
            let searchURL = string(item, keys: ["searchUrl", "searchURL"]) ?? ""
            guard !baseURL.isEmpty || !searchURL.isEmpty else { return nil }
            return BookSource(name: name, baseURL: baseURL, searchURL: searchURL, enabled: (item["enabled"] as? Bool) ?? true)
        }
    }
    private static func string(_ item: [String: Any], keys: [String]) -> String? { for key in keys { if let value = item[key] as? String, !value.isEmpty { return value } }; return nil }
    private enum ImportError: LocalizedError { case invalidFormat; var errorDescription: String? { "JSON 格式无效，请选择书源 JSON 文件。" } }
}
