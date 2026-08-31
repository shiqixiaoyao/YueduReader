import SwiftUI

struct SettingsView: View {
    @State private var showingAddSource = false
    var body: some View {
        NavigationStack {
            List {
                Section("阅读") {
                    Label("阅读设置", systemImage: "textformat.size")
                    Label("主题与显示", systemImage: "paintbrush")
                }
                Section("书源") {
                    Button { showingAddSource = true } label: { Label("添加书源", systemImage: "plus.circle") }
                    NavigationLink { SourceManagerView() } label: { Label("书源管理", systemImage: "server.rack") }
                }
                Section("关于") { Label("关于 YueduReader", systemImage: "info.circle") }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showingAddSource) { AddSourceView() }
        }
    }
}
