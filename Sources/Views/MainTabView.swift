import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BookshelfView().tabItem { Label("书架", systemImage: "books.vertical") }
            LibraryView().tabItem { Label("书城", systemImage: "building.columns") }
            SettingsView().tabItem { Label("设置", systemImage: "gearshape") }
        }
        .tint(.accentColor)
    }
}
