import SwiftUI

enum CalendarMode: String, CaseIterable, Identifiable, Hashable {
    case day
    case week

    var id: String { rawValue }
    var label: String { self == .day ? "일" : "주" }
}

struct CalendarView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedDate = Date()
    @State private var mode: CalendarMode = .day
    @State private var showingBlockSheet = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar.padding(16).background(Color.nouCard).overlay(alignment: .bottom) { Rectangle().fill(Color.nouBorder).frame(height: 1) }
            if mode == .day { dayView(selectedDate) } else { weekView }
        }
        .navigationTitle("캘린더")
        .sheet(isPresented: $showingBlockSheet) { TimeBlockForm(date: selectedDate) }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Picker("보기", selection: $mode) {
                ForEach(CalendarMode.allCases) { mode in Text(mode.label).tag(mode) }
            }
            .pickerStyle(.segmented)
            .frame(width: 160)
            Button { shift(-1) } label: { Image(systemName: "chevron.left") }
            Button("오늘") { selectedDate = Date() }
            Button { shift(1) } label: { Image(systemName: "chevron.right") }
            Spacer()
            Text(DateUtils.dayFormatter.string(from: selectedDate)).font(.headline)
            Button { showingBlockSheet = true } label: { Label("타임블록", systemImage: "plus") }
        }
    }

    private func dayView(_ date: Date) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CardView {
                    SectionHeader(title: "작업")
                    let tasks = store.tasks(on: date)
                    if tasks.isEmpty {
                        EmptyStateView(title: "작업 없음", message: "이 날짜에 연결된 작업이 없습니다.")
                    } else {
                        ForEach(tasks) { task in
                            TaskRowView(task: task) { store.toggleTask(task) }
                            Divider()
                        }
                    }
                }

                CardView {
                    SectionHeader(title: "타임블록")
                    let blocks = store.timeBlocks(on: date)
                    if blocks.isEmpty {
                        EmptyStateView(title: "타임블록 없음", message: "하루의 리듬을 간단히 배치해 보세요.")
                    } else {
                        ForEach(blocks) { block in
                            TimeBlockRowView(block: block) { store.deleteTimeBlock(block) }
                            Divider()
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    private var weekView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
                ForEach(DateUtils.weekDays(containing: selectedDate), id: \.self) { day in
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            selectedDate = day
                            mode = .day
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(DateUtils.shortDayFormatter.string(from: day)).font(.headline)
                                Text(DateUtils.isSameDay(day, Date()) ? "오늘" : "\(store.tasks(on: day).count) 작업")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)

                        ForEach(store.timeBlocks(on: day).prefix(4)) { block in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(block.title).font(.caption.weight(.semibold)).lineLimit(2)
                                Text(DateUtils.timeFormatter.string(from: block.start)).font(.caption2).foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.nouAccent.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .frame(minHeight: 220, alignment: .top)
                    .background(Color.nouCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay { RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(DateUtils.isSameDay(day, selectedDate) ? Color.nouAccent.opacity(0.55) : Color.nouBorder, lineWidth: 1) }
                }
            }
            .padding(20)
        }
    }

    private func shift(_ amount: Int) {
        selectedDate = DateUtils.addingDays(mode == .day ? amount : amount * 7, to: selectedDate)
    }
}
