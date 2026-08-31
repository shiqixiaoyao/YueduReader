import SwiftUI
import SwiftData

struct AddSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var name = ""
    @State private var baseURL = ""
    @State private var searchURL = ""
    @State private var enabled = true

    var body: some View {
        NavigationStack {
            Form {
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        modelContext.insert(BookSource(name: name.trimmingCharacters(in: .whitespacesAndNewlines), baseURL: baseURL, searchURL: searchURL, enabled: enabled))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || baseURL.isEmpty)
                }
            }
        }
    }
}
