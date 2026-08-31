import SwiftUI
import SwiftData

struct SourceManagerView: View {
    @Environment(\.modelContext) private var context; @Query(sort: \BookSource.name) private var sources: [BookSource]
    @State private var name = ""; @State private var url = ""
    var body: some View { NavigationStack { List { Section("Add source") { TextField("Name", text: $name); TextField("Search URL ({key})", text: $url); Button("Add") { context.insert(BookSource(name: name, baseURL: url, searchURL: url)); name = ""; url = "" }.disabled(name.isEmpty || url.isEmpty) }; Section("Sources") { ForEach(sources) { source in Toggle(source.name, isOn: Binding(get: { source.enabled }, set: { source.enabled = $0 })) }.onDelete { offsets in offsets.map { sources[$0] }.forEach(context.delete) } } }.navigationTitle("Book Sources") } }
}
