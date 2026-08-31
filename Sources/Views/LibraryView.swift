import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""
    var body: some View {
        NavigationStack {
            ContentUnavailableView("暂无书源内容", systemImage: "book.closed", description: Text("请在设置中添加书源，开始发现好书。"))
                .navigationTitle("书城")
                .searchable(text: $searchText, prompt: "搜索书名或作者")
        }
    }
}
