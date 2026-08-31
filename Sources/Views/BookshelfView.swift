import SwiftUI
import SwiftData

struct BookshelfView: View {
    @Query(sort: \Book.title) private var books: [Book]
    @State private var showingSources = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if books.isEmpty {
                    ContentUnavailableView("书架为空", systemImage: "books.vertical", description: Text("添加一本书，开始阅读吧。"))
                } else {
                    List(books) { book in
                        NavigationLink { BookDetailView(book: book) } label: {
                            Label(book.title, systemImage: "book.closed")
                        }
                    }
                }
            }
            .navigationTitle("书架")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingSources = true } label: { Image(systemName: "server.rack") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingSources) { SourceManagerView() }
            .sheet(isPresented: $showingAdd) { AddBookView() }
        }
    }
}

private struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var title = ""
    @State private var author = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("书名", text: $title)
                TextField("作者", text: $author)
            }
            .navigationTitle("添加书籍")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        modelContext.insert(Book(title: title, author: author))
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
