import SwiftUI

struct InboxView: View {
    @EnvironmentObject private var store: AppStore
    @State private var editingItem: InboxItem?
    @State private var showingAddSheet = false

    var body: some View {
        List {
            ForEach(store.inboxItems) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.title).font(.headline)
                        Spacer()
                        Text(item.status.label).font(.caption).foregroundStyle(.secondary)
                    }
                    if !item.note.isEmpty {
                        Text(item.note).font(.subheadline).foregroundStyle(.secondary)
                    }
                    HStack {
                        Button("Today로 이동") { store.moveInboxItemToToday(item) }
                        Button("처리 완료") { store.processInboxItem(item) }
                        Spacer()
                        Button("수정") { editingItem = item }
                        Button("삭제", role: .destructive) { store.deleteInboxItem(item) }
                    }
                    .font(.caption)
                }
                .padding(.vertical, 6)
            }
        }
        .overlay {
            if store.inboxItems.isEmpty {
                EmptyStateView(title: "인박스가 비어 있습니다", message: "떠오른 생각, 링크, 할 일을 먼저 담아두세요.")
                    .padding(24)
            }
        }
        .navigationTitle("인박스")
        .toolbar {
            Button { showingAddSheet = true } label: { Label("추가", systemImage: "plus") }
        }
        .sheet(isPresented: $showingAddSheet) { InboxItemForm(mode: .add) }
        .sheet(item: $editingItem) { item in InboxItemForm(mode: .edit(item)) }
    }
}

struct InboxItemForm: View {
    enum Mode { case add; case edit(InboxItem) }

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let mode: Mode
    @State private var title = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("캡처") {
                    TextField("제목", text: $title)
                    TextField("메모", text: $note, axis: .vertical)
                        .lineLimit(4...8)
                }
            }
            .navigationTitle(navigationTitle)
            .onAppear {
                if case let .edit(item) = mode {
                    title = item.title
                    note = item.note
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        switch mode {
                        case .add: store.addInboxItem(title: title, note: note)
                        case .edit(let item): store.updateInboxItem(item, title: title, note: note)
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        if case .add = mode { return "인박스 추가" }
        return "인박스 수정"
    }
}
