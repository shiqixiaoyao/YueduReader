import SwiftUI

struct ReaderContainerView: View {
    let chapter: Chapter
    @State private var fontSize: Double = 18
    var body: some View { ScrollView { Text(chapter.content).font(.system(size: fontSize, design: .serif)).lineSpacing(8).padding() }.navigationTitle(chapter.title).toolbar { Menu { Slider(value: $fontSize, in: 12...30) } label: { Image(systemName: "textformat.size") } } }
}
