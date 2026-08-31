import SwiftUI
import SwiftData

struct BookshelfView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Book.title) private var books: [Book]
    @State private var showingSources = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if books.isEmpty { ContentUnavailableView("No Books", systemImage: "books.vertical", description: Text("Add a book to begin reading.")) }
                else { List(books) { book in NavigationLink { BookDetailView(book: book) } label: { Label(book.title, systemImage: "book.closed") } } }
            }
            .navigationTitle("Bookshelf")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button { showingSources = true } label: { Image(systemName: "server.rack") } }; ToolbarItem(placement: .topBarTrailing) { Button { showingAdd = true } label: { Image(systemName: "plus") } } }
            .sheet(isPresented: $showingSources) { SourceManagerView() }
            .sheet(isPresented: $showingAdd) { AddBookView() }
        }
    }
}

private struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss; @Environment(\.modelContext) private var context
    @State private var title = ""; @State private var author = ""
    var body: some View { NavigationStack { Form { TextField("Title", text: $title); TextField("Author", text: $author) }.navigationTitle("Add Book").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Add") { context.insert(Book(title: title, author: author)); dismiss() }.disabled(title.isEmpty) } } } }
}
