import SwiftUI

struct AddSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var url = ""
    @State private var enabled = true
    var body: some View {
        NavigationStack {
            Form {
                Section("书源信息") {
                    TextField("名称", text: $name)
                    TextField("地址", text: $url)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    Toggle("启用书源", isOn: $enabled)
                }
                Section { Text("书源将用于搜索和获取书籍内容。请确认地址可信。").font(.footnote).foregroundStyle(.secondary) }
            }
            .navigationTitle("添加书源")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("保存") { dismiss() }.disabled(name.isEmpty || url.isEmpty) }
            }
        }
    }
}
