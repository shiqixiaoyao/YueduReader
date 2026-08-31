import SwiftUI
import SwiftData
import Foundation

struct AddSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var name = ""
    @State private var baseURL = ""
    @State private var searchURL = ""
    @State private var jsonText = ""
    @State private var enabled = true
    @State private var message: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section("本地导入") {
                    TextEditor(text: $jsonText).frame(minHeight: 120).overlay(alignment: .topLeading) {
                        if jsonText.isEmpty { Text("请粘贴书源 JSON 内容或输入书源 URL").foregroundStyle(.secondary).padding(.top, 8).padding(.leading, 5) }
                    }
                    Button(isLoading ? "正在导入" : "导入 JSON 内容") { importJSON() }.disabled(jsonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                Section("书源信息") {
                    TextField("名称", text: $name)
                    TextField("基础地址", text: $baseURL).textInputAutocapitalization(.never).keyboardType(.URL)
                    TextField("搜索地址（使用 {key} 作为关键词）", text: $searchURL).textInputAutocapitalization(.never).keyboardType(.URL)
                    Toggle("启用书源", isOn: $enabled)
                }
            }
            .navigationTitle("添加书源")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("保存") { saveManual() }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || baseURL.isEmpty) }
            }
            .alert("导入结果", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("确定") { message = nil } } message: { Text(message ?? "") }
        }
    }

    private func saveManual() {
        modelContext.insert(BookSource(name: name.trimmingCharacters(in: .whitespacesAndNewlines), baseURL: baseURL, searchURL: searchURL, enabled: enabled))
        try? modelContext.save(); dismiss()
    }

    private func importJSON() {
        isLoading = true
        let input = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: input), url.scheme?.hasPrefix("http") == true {
            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async {
                    isLoading = false
                    guard let data, error == nil else { message = "读取书源 URL 失败。"; return }
                    insertJSON(data)
                }
            }.resume()
        } else {
            insertJSON(Data(input.utf8)); isLoading = false
        }
    }

    private func insertJSON(_ data: Data) {
        do {
            let object = try JSONSerialization.jsonObject(with: data)
            let items: [[String: Any]]
            if let array = object as? [[String: Any]] { items = array }
            else if let item = object as? [String: Any] { items = [item] }
            else { throw NSError(domain: "书源", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON 格式无效。"]) }
            var count = 0
            for item in items {
                let sourceName = (item["bookSourceName"] as? String) ?? (item["name"] as? String) ?? "未命名书源"
                let sourceURL = (item["bookSourceUrl"] as? String) ?? (item["baseURL"] as? String) ?? (item["url"] as? String) ?? ""
                let sourceSearch = (item["searchUrl"] as? String) ?? (item["searchURL"] as? String) ?? ""
                guard !sourceURL.isEmpty || !sourceSearch.isEmpty else { continue }
                modelContext.insert(BookSource(name: sourceName, baseURL: sourceURL, searchURL: sourceSearch, enabled: (item["enabled"] as? Bool) ?? true)); count += 1
            }
            try modelContext.save(); message = count == 0 ? "没有找到可导入的书源。" : "已成功导入 \(count) 个书源。"
        } catch { message = "导入失败：\(error.localizedDescription)" }
    }
}
