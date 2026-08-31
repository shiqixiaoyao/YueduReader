import SwiftUI
import SwiftData

@main
struct YueduReaderApp: App {
    var body: some Scene {
        WindowGroup { MainTabView() }
            .modelContainer(for: [Book.self, BookSource.self, Chapter.self])
    }
}
