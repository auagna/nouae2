import SwiftUI

struct TaskRowView: View {
    let task: Task
    var onToggle: () -> Void
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.status == .done ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(task.status == .done ? Color.nouAccent : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.status == .done)
                    .foregroundStyle(task.status == .done ? .secondary : .primary)
                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Menu {
                if let onEdit {
                    Button("수정", action: onEdit)
                }
                if let onDelete {
                    Button("삭제", role: .destructive, action: onDelete)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}
