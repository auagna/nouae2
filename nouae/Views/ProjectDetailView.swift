import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let projectId: UUID
    @State private var showingEditSheet = false
    @State private var showingTaskSheet = false
    @State private var showingWidgetSheet = false
    @State private var showingLogSheet = false

    private var project: Project? { store.projects.first { $0.id == projectId } }

    var body: some View {
        Group {
            if let project {
                ScrollView {
                    VStack(spacing: 16) {
                        CardView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(project.title).font(.largeTitle.weight(.semibold))
                                Text(project.description).foregroundStyle(.secondary)
                                Text(project.status.label)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.nouAccent.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }
                        }

                        CardView {
                            SectionHeader(title: "프로젝트 작업", actionTitle: "추가") { showingTaskSheet = true }
                            if project.tasks.isEmpty {
                                EmptyStateView(title: "작업 없음", message: "이 프로젝트의 다음 행동을 추가하세요.")
                            } else {
                                ForEach(project.tasks) { task in
                                    TaskRowView(task: task) { store.toggleTask(task) } onDelete: { store.deleteTask(task) }
                                    Divider()
                                }
                            }
                        }

                        CardView {
                            SectionHeader(title: "위젯", actionTitle: "추가") { showingWidgetSheet = true }
                            if project.widgets.isEmpty {
                                EmptyStateView(title: "위젯 없음", message: "메모나 체크리스트를 붙여둘 수 있습니다.")
                            } else {
                                ForEach(project.widgets) { widget in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(widget.title).font(.headline)
                                        if !widget.content.isEmpty { Text(widget.content).foregroundStyle(.secondary) }
                                        if let items = widget.items {
                                            ForEach(items) { item in
                                                Button {
                                                    store.toggleProjectChecklistItem(projectId: project.id, widgetId: widget.id, itemId: item.id)
                                                } label: {
                                                    Label(item.title, systemImage: item.isDone ? "checkmark.circle.fill" : "circle")
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                    Divider()
                                }
                            }
                        }

                        CardView {
                            SectionHeader(title: "프로젝트 로그", actionTitle: "추가") { showingLogSheet = true }
                            if project.logs.isEmpty {
                                EmptyStateView(title: "기록 없음", message: "진행 중 배운 점이나 결정을 남겨두세요.")
                            } else {
                                ForEach(project.logs) { log in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(log.content)
                                        Text(DateUtils.dayFormatter.string(from: log.date)).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(20)
                }
                .navigationTitle(project.title)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("수정") { showingEditSheet = true }
                        Button("삭제", role: .destructive) {
                            store.deleteProject(project)
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showingEditSheet) { ProjectForm(mode: .edit(project)) }
                .sheet(isPresented: $showingTaskSheet) { TaskForm(mode: .add(date: Date(), projectId: project.id)) }
                .sheet(isPresented: $showingWidgetSheet) { ProjectWidgetForm(projectId: project.id) }
                .sheet(isPresented: $showingLogSheet) { ProjectLogForm(projectId: project.id) }
            } else {
                EmptyStateView(title: "프로젝트를 찾을 수 없습니다", message: "삭제되었거나 데이터가 갱신되었습니다.").padding()
            }
        }
    }
}

struct ProjectWidgetForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let projectId: UUID
    @State private var type: ProjectWidgetType = .memo
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("유형", selection: $type) { ForEach(ProjectWidgetType.allCases) { type in Text(type.label).tag(type) } }
                TextField("제목", text: $title)
                TextField("내용", text: $content, axis: .vertical)
            }
            .navigationTitle("위젯 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        store.addProjectWidget(projectId: projectId, type: type, title: title, content: content)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProjectLogForm: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let projectId: UUID
    @State private var content = ""

    var body: some View {
        NavigationStack {
            Form { TextField("기록", text: $content, axis: .vertical).lineLimit(4...8) }
                .navigationTitle("로그 추가")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("저장") {
                            store.addProjectLog(projectId: projectId, content: content)
                            dismiss()
                        }
                    }
                }
        }
    }
}
