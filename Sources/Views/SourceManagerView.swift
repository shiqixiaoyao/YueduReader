import SwiftUI
import SwiftData

struct SourceManagerView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query(sort: \BookSource.name) private var sources: [BookSource]
    @State private var showingAddSource = false

    var body: some View {
        NavigationStack {
            List {
                if sources.isEmpty {
                    ContentUnavailableView("暂无书源", systemImage: "server.rack", description: Text("添加一个书源后即可搜索书籍。"))
                } else {
                    ForEach(sources) { source in
                        Toggle(source.name, isOn: Binding(get: { source.enabled }, set: { source.enabled = $0 }))
                    }
                    .onDelete { offsets in
                        offsets.map { sources[$0] }.forEach(modelContext.delete)
                    }
                }
            }
            .navigationTitle("书源管理")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showingAddSource = true } label: { Image(systemName: "plus") } } }
            .sheet(isPresented: $showingAddSource) { AddSourceView() }
        }
    }
}
