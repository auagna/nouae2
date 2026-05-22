import SwiftUI

struct TimeBlockRowView: View {
    let block: TimeBlock
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(DateUtils.timeFormatter.string(from: block.start))
                Text(DateUtils.timeFormatter.string(from: block.end))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
            .frame(width: 48, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(block.title)
                    .font(.subheadline.weight(.semibold))
                Text(block.type.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let note = block.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}
