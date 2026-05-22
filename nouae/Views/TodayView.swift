import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showingTaskSheet = false
    @State private var showingBlockSheet = false
    @State private var editingTask: Task?

    private var todayTasks: [Task] { store.tasks(on: Date()) }
    private var todayBlocks: [TimeBlock] { store.timeBlocks(on: Date()) }
    private var completionText: String { "\(todayTasks.filter { $0.status == .done }.count)/\(todayTasks.count) 완료" }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardView {
                    SectionHeader(title: "오늘의 초점")
                    TextEditor(text: $store.focusStatement)
                        .frame(minHeight: 86)
                        .scrollContentBackground(.hidden)
                        .onChange(of: store.focusStatement) { _ in store.save() }
                }

                CardView {
                    SectionHeader(title: "타임블록", actionTitle: "추가") { showingBlockSheet = true }
                    if todayBlocks.isEmpty {
                        EmptyStateView(title: "배치된 시간이 없습니다", message: "집중할 시간을 먼저 잡아두세요.")
                    } else {
                        ForEach(todayBlocks) { block in
                            TimeBlockRowView(block: block) { store.deleteTimeBlock(block) }
                            Divider()
                        }
                    }
                }

                CardView {
                    SectionHeader(title: "데일리 체크리스트", actionTitle: "추가") { showingTaskSheet = true }
                    if todayTasks.isEmpty {
                        EmptyStateView(title: "오늘 작업 없음", message: "실행할 일을 작게 추가하세요.")
                    } else {
                        ForEach(todayTasks) { task in
                            TaskRowView(task: task) { store.toggleTask(task) } onEdit: { editingTask = task } onDelete: { store.deleteTask(task) }
                            Divider()
                        }
                    }
                }

                CardView {
                    SectionHeader(title: "빠른 메모")
                    TextEditor(text: $store.quickMemo)
                        .frame(minHeight: 96)
                        .scrollContentBackground(.hidden)
                        .onChange(of: store.quickMemo) { _ in store.save() }
                }

                CardView {
                    SectionHeader(title: "완료 요약")
                    Text(completionText).font(.title3.weight(.semibold))
                    Text("끝난 일과 남은 일을 Review에서 정리할 수 있습니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
        }
        .navigationTitle("오늘")
        .toolbar { Button { showingTaskSheet = true } label: { Label("작업 추가", systemImage: "plus") } }
        .sheet(isPresented: $showingTaskSheet) { TaskForm(mode: .add(date: Date(), projectId: nil)) }
        .sheet(item: $editingTask) { task in TaskForm(mode: .edit(task)) }
        .sheet(isPresented: $showingBlockSheet) { TimeBlockForm(date: Date()) }
    }
}

struct TaskForm: View {
    enum Mode { case add(date: Date, projectId: UUID?); case edit(Task) }

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let mode: Mode
    @State private var title = ""
    @State private var note = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("작업") {
                    TextField("제목", text: $title)
                    TextField("메모", text: $note, axis: .vertical)
                    DatePicker("날짜", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(titleText)
            .onAppear {
                switch mode {
                case .add(let startDate, _): date = startDate
                case .edit(let task):
                    title = task.title
                    note = task.note
                    date = task.date
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        switch mode {
                        case .add(_, let projectId): store.addTask(title: title, note: note, date: date, projectId: projectId)
                        case .edit(let task): store.updateTask(task, title: title, note: note, date: date)
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private var titleText: String {
        if case .edit = mode { return "작업 수정" }
        return "작업 추가"
    }
}

struct TimeBlockForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let date: Date
    @State private var title = ""
    @State private var start = Date()
    @State private var end = Date().addingTimeInterval(3600)
    @State private var type: TimeBlockType = .timeBlock
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("시간") {
                    TextField("제목", text: $title)
                    DatePicker("시작", selection: $start, displayedComponents: [.hourAndMinute])
                    DatePicker("종료", selection: $end, displayedComponents: [.hourAndMinute])
                    Picker("유형", selection: $type) {
                        ForEach(TimeBlockType.allCases) { type in Text(type.label).tag(type) }
                    }
                    TextField("메모", text: $note, axis: .vertical)
                }
            }
            .navigationTitle("타임블록 추가")
            .onAppear {
                start = DateUtils.hourDate(day: date, hour: 9)
                end = DateUtils.hourDate(day: date, hour: 10)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let startDate = DateUtils.calendar.date(bySettingHour: DateUtils.calendar.component(.hour, from: start), minute: DateUtils.calendar.component(.minute, from: start), second: 0, of: date) ?? start
                        let endDate = DateUtils.calendar.date(bySettingHour: DateUtils.calendar.component(.hour, from: end), minute: DateUtils.calendar.component(.minute, from: end), second: 0, of: date) ?? end
                        store.addTimeBlock(title: title, start: startDate, end: endDate, date: date, type: type, projectId: nil, note: note)
                        dismiss()
                    }
                }
            }
        }
    }
}
