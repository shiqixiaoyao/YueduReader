import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Bindable var book: Book
    var body: some View { List { Section { Text(book.author.isEmpty ? "Unknown author" : book.author).foregroundStyle(.secondary) }; Section("Chapters") { if book.chapters.isEmpty { Text("No chapters yet").foregroundStyle(.secondary) } else { ForEach(book.chapters.sorted { $0.index < $1.index }) { chapter in NavigationLink(chapter.title) { ReaderContainerView(chapter: chapter) } } } } }.navigationTitle(book.title) }
}
