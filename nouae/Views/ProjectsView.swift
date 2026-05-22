import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                    ForEach(store.projects) { project in
                        NavigationLink(value: project.id) { ProjectCardView(project: project) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .overlay {
                if store.projects.isEmpty {
                    EmptyStateView(title: "프로젝트가 없습니다", message: "삶을 움직이는 흐름을 프로젝트로 묶어보세요.")
                        .padding(24)
                }
            }
            .navigationTitle("프로젝트")
            .toolbar { Button { showingAddSheet = true } label: { Label("프로젝트 추가", systemImage: "plus") } }
            .navigationDestination(for: UUID.self) { id in ProjectDetailView(projectId: id) }
            .sheet(isPresented: $showingAddSheet) { ProjectForm(mode: .add) }
        }
    }
}

struct ProjectForm: View {
    enum Mode { case add; case edit(Project) }

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let mode: Mode
    @State private var title = ""
    @State private var description = ""
    @State private var status: ProjectStatus = .active

    var body: some View {
        NavigationStack {
            Form {
                Section("프로젝트") {
                    TextField("제목", text: $title)
                    TextField("설명", text: $description, axis: .vertical)
                    Picker("상태", selection: $status) {
                        ForEach(ProjectStatus.allCases) { status in Text(status.label).tag(status) }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .onAppear {
                if case let .edit(project) = mode {
                    title = project.title
                    description = project.description
                    status = project.status
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        switch mode {
                        case .add: store.addProject(title: title, description: description, status: status)
                        case .edit(let project): store.updateProject(project, title: title, description: description, status: status)
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        if case .edit = mode { return "프로젝트 수정" }
        return "프로젝트 추가"
    }
}
