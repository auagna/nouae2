import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showingMoodSheet = false

    private var todayTasks: [Task] { store.tasks(on: Date()) }
    private var todayBlocks: [TimeBlock] { store.timeBlocks(on: Date()) }
    private var todayMood: MoodLog? { store.moodLogs.first { DateUtils.isSameDay($0.date, Date()) } }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)], spacing: 16) {
                CardView {
                    SectionHeader(title: "Today Focus")
                    TextEditor(text: $store.focusStatement)
                        .frame(minHeight: 72)
                        .scrollContentBackground(.hidden)
                        .onChange(of: store.focusStatement) { _ in store.save() }
                }

                CardView {
                    SectionHeader(title: "Current Time Blocks")
                    if todayBlocks.isEmpty {
                        EmptyStateView(title: "오늘 타임블록 없음", message: "Today에서 시간을 배치해 보세요.")
                    } else {
                        ForEach(todayBlocks.prefix(3)) { block in
                            TimeBlockRowView(block: block)
                            Divider()
                        }
                    }
                }

                CardView {
                    SectionHeader(title: "Active Projects")
                    if store.activeProjects().isEmpty {
                        EmptyStateView(title: "진행 중 프로젝트 없음", message: "Projects에서 새 프로젝트를 만들 수 있습니다.")
                    } else {
                        ForEach(store.activeProjects().prefix(4)) { project in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(project.title).font(.subheadline.weight(.semibold))
                                Text(project.description).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                            }
                            Divider()
                        }
                    }
                }

                CardView {
                    SectionHeader(title: "Daily Checklist")
                    if todayTasks.isEmpty {
                        EmptyStateView(title: "오늘 작업 없음", message: "Today에서 실행할 일을 추가하세요.")
                    } else {
                        ForEach(todayTasks.prefix(5)) { task in
                            TaskRowView(task: task) { store.toggleTask(task) }
                        }
                    }
                }

                CardView {
                    SectionHeader(title: "Mood / Energy Quick Log", actionTitle: "기록") { showingMoodSheet = true }
                    if let todayMood {
                        Text("기분 \(todayMood.moodScore) / 에너지 \(todayMood.energyScore)")
                            .font(.title3.weight(.semibold))
                        Text(todayMood.note.isEmpty ? "메모 없음" : todayMood.note)
                            .foregroundStyle(.secondary)
                    } else {
                        EmptyStateView(title: "아직 기록 없음", message: "오늘의 기분과 에너지를 빠르게 남겨 보세요.")
                    }
                }

                CardView {
                    SectionHeader(title: "Recent Notes")
                    if store.recentInboxItems().isEmpty {
                        EmptyStateView(title: "최근 인박스 없음", message: "Inbox에서 생각을 붙잡아 둘 수 있습니다.")
                    } else {
                        ForEach(store.recentInboxItems()) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title).font(.subheadline.weight(.semibold))
                                Text(item.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                            }
                            Divider()
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("홈")
        .sheet(isPresented: $showingMoodSheet) { MoodLogForm() }
    }
}

struct MoodLogForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var moodScore = 3.0
    @State private var energyScore = 3.0
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("오늘 상태") {
                    Stepper("기분 \(Int(moodScore))", value: $moodScore, in: 1...5, step: 1)
                    Stepper("에너지 \(Int(energyScore))", value: $energyScore, in: 1...5, step: 1)
                    TextField("메모", text: $note, axis: .vertical)
                }
            }
            .navigationTitle("상태 기록")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        store.addMoodLog(moodScore: Int(moodScore), energyScore: Int(energyScore), note: note)
                        dismiss()
                    }
                }
            }
        }
    }
}
