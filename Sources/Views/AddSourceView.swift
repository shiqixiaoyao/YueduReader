import SwiftUI
import SwiftData

struct AddSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var jsonText = ""
    @State private var message: String?
    var body: some View { NavigationStack { Form { Section("粘贴 JSON 或 URL") { TextEditor(text: $jsonText).frame(minHeight: 180); Button("导入") { importJSON() }.disabled(jsonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) } }.navigationTitle("添加书源").toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } } }.alert("导入结果", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("确定") {} } message: { Text(message ?? "") } } }
    private func importJSON() { let input = jsonText.trimmingCharacters(in: .whitespacesAndNewlines); if let url = URL(string: input), url.scheme?.hasPrefix("http") == true { Task { do { var request = URLRequest(url: url); request.timeoutInterval = 20; request.setValue("Mozilla/5.0 YueduReader/1.0", forHTTPHeaderField: "User-Agent"); let (data, _) = try await URLSession.shared.data(for: request); insert(data) } catch { message = "读取失败：\(error.localizedDescription)" } } } else { insert(Data(input.utf8)) } }
    private func insert(_ data: Data) { do { let parsed = try BookSourceFileParser.parse(data: data); var count = 0; for source in parsed where !sourcesDuplicate(source) { modelContext.insert(source); count += 1 }; try modelContext.save(); message = "成功导入 \(count) 个书源" } catch { message = "导入失败：\(error.localizedDescription)" } }
    private func sourcesDuplicate(_ source: BookSource) -> Bool { let descriptor = FetchDescriptor<BookSource>(); return ((try? modelContext.fetch(descriptor)) ?? []).contains { $0.name == source.name || $0.baseURL == source.baseURL } }
}
