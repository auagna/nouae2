import SwiftUI

struct ProjectCardView: View {
    let project: Project

    var body: some View {
        CardView {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.title)
                        .font(.headline)
                    Text(project.description.isEmpty ? "설명이 없습니다." : project.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Text(project.status.label)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.nouAccent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }

            HStack {
                Label("\(project.tasks.filter { $0.status == .done }.count)/\(project.tasks.count)", systemImage: "checkmark.circle")
                Label("\(project.widgets.count)", systemImage: "square.text.square")
                Label("\(project.logs.count)", systemImage: "doc.text")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
