import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SourceManagerView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query(sort: [SortDescriptor(\BookSource.name)]) private var sources: [BookSource]
    @State private var showingAddSource = false
    @State private var showingFileImporter = false
    @State private var message: String?
    var body: some View {
        NavigationStack { List {
            Section { Button("恢复默认内置书源") { restore() }; Button("从本地文件导入") { showingFileImporter = true }; Button("手动添加书源") { showingAddSource = true } }
            Section("已添加的书源") { ForEach(sources) { source in Toggle(source.name, isOn: Binding(get: { source.enabled }, set: { source.enabled = $0; try? modelContext.save() })) }.onDelete { offsets in offsets.map { sources[$0] }.forEach(modelContext.delete); try? modelContext.save() } }
        }.navigationTitle("书源管理").sheet(isPresented: $showingAddSource) { AddSourceView() }.fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in importFiles(result) }.alert("书源管理", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("确定") {} } message: { Text(message ?? "") } }
    }
    private func importFiles(_ result: Result<[URL], Error>) { do { var count = 0; for url in try result.get() { let scoped = url.startAccessingSecurityScopedResource(); defer { if scoped { url.stopAccessingSecurityScopedResource() } }; for source in try BookSourceFileParser.parse(data: Data(contentsOf: url)) where !sources.contains(where: { $0.name == source.name || $0.baseURL == source.baseURL }) { modelContext.insert(source); count += 1 } }; try modelContext.save(); message = "成功导入 \(count) 个书源" } catch { message = "导入失败：\(error.localizedDescription)" } }
    private func restore() { guard let url = Bundle.main.url(forResource: "DefaultSources", withExtension: "json"), let data = try? Data(contentsOf: url) else { message = "找不到内置书源"; return }; importFiles(.success([url])) }
}
