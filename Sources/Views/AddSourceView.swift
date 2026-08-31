import SwiftUI
import SwiftData
import Foundation

struct AddSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var jsonText = ""
    @State private var message: String?
    var body: some View {
        NavigationStack { Form {
            Section("粘贴 JSON 或 URL") { TextEditor(text: $jsonText).frame(minHeight: 180); Button("导入") { importJSON() }.disabled(jsonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }
        }.navigationTitle("添加书源").toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } } }
        .alert("导入结果", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("确定") {} } message: { Text(message ?? "") }}
    }
    private func importJSON() {
        let input = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: input), url.scheme?.hasPrefix("http") == true { URLSession.shared.dataTask(with: url) { data, _, error in DispatchQueue.main.async { if let data, error == nil { insert(data) } else { message = error?.localizedDescription ?? "读取书源 URL 失败" } } }.resume() } else { insert(Data(input.utf8)) }
    }
    private func insert(_ data: Data) {
        do { let object = try JSONSerialization.jsonObject(with: data); let items = (object as? [[String: Any]]) ?? (object as? [String: Any]).map { [$0] } ?? []; var count = 0
            for item in items { let name = (item["bookSourceName"] as? String) ?? (item["name"] as? String) ?? (item["title"] as? String) ?? "未命名书源"; let url = (item["bookSourceUrl"] as? String) ?? (item["url"] as? String) ?? (item["baseUrl"] as? String) ?? ""; let search = (item["searchUrl"] as? String) ?? (item["searchURL"] as? String) ?? (((item["ruleSearch"] as? [String: Any])?["searchUrl"] as? String) ?? ""); guard !url.isEmpty || !search.isEmpty else { continue }; let enabled = (item["enabled"] as? Bool) ?? ((item["enabled"] as? Int) != 0); modelContext.insert(BookSource(name: name, baseURL: url, searchURL: search, enabled: enabled, rawJSON: String(data: (try? JSONSerialization.data(withJSONObject: item)) ?? Data(), encoding: .utf8) ?? "")); count += 1 }
            try modelContext.save(); message = "成功导入 \(count) 个书源"
        } catch { message = "导入失败：\(error.localizedDescription)" }
    }
}
