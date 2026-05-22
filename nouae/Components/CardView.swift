import SwiftUI

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.nouCard)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.nouBorder, lineWidth: 1)
        }
    }
}

extension Color {
    static let nouBackground = Color(red: 0.965, green: 0.962, blue: 0.948)
    static let nouCard = Color(red: 0.992, green: 0.990, blue: 0.982)
    static let nouBorder = Color.black.opacity(0.09)
    static let nouAccent = Color(red: 0.20, green: 0.26, blue: 0.24)
}
