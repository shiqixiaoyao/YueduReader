import SwiftUI
import SwiftData

@main
struct YueduReaderApp: App {
    var body: some Scene {
        WindowGroup { BookshelfView() }
            .modelContainer(for: [Book.self, BookSource.self, Chapter.self])
    }
}
