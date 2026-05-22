import Combine
import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var inboxItems: [InboxItem] = []
    @Published var tasks: [Task] = []
    @Published var timeBlocks: [TimeBlock] = []
    @Published var projects: [Project] = []
    @Published var moodLogs: [MoodLog] = []
    @Published var reviews: [Review] = []
    @Published var recents: [RecentItem] = []
    @Published var focusStatement: String = "오늘 가장 중요한 한 가지를 정합니다."
    @Published var quickMemo: String = ""
    @Published var lastStorageError: String?

    private let dataStore = LocalDataStore()
    private let focusKey = "nouae.focusStatement"
    private let quickMemoKey = "nouae.quickMemo"

    init() {
        focusStatement = UserDefaults.standard.string(forKey: focusKey) ?? focusStatement
        quickMemo = UserDefaults.standard.string(forKey: quickMemoKey) ?? quickMemo
        load()
    }

    var appData: AppData {
        AppData(inboxItems: inboxItems, tasks: tasks, timeBlocks: timeBlocks, projects: projects, moodLogs: moodLogs, reviews: reviews, recents: recents)
    }

    func load() {
        do {
            if let data = try dataStore.load() {
                apply(data)
            } else {
                apply(SeedData.make())
                save()
            }
        } catch {
            lastStorageError = error.localizedDescription
            apply(SeedData.make())
        }
    }

    func save() {
        do {
            UserDefaults.standard.set(focusStatement, forKey: focusKey)
            UserDefaults.standard.set(quickMemo, forKey: quickMemoKey)
            try dataStore.save(appData)
            lastStorageError = nil
        } catch {
            lastStorageError = error.localizedDescription
        }
    }

    func exportJSON() -> String { dataStore.exportString(appData) }

    func importJSON(_ json: String) -> Bool {
        do {
            let data = try dataStore.importString(json)
            apply(data)
            save()
            return true
        } catch {
            lastStorageError = error.localizedDescription
            return false
        }
    }

    func resetData() {
        do {
            try dataStore.reset()
            apply(SeedData.make())
            save()
        } catch {
            lastStorageError = error.localizedDescription
        }
    }

    func addInboxItem(title: String, note: String) {
        let item = InboxItem(title: title.trimmedFallback("새 인박스"), note: note)
        inboxItems.insert(item, at: 0)
        touchRecent(id: item.id, type: .inbox, title: item.title)
        save()
    }

    func updateInboxItem(_ item: InboxItem, title: String, note: String) {
        guard let index = inboxItems.firstIndex(where: { $0.id == item.id }) else { return }
        inboxItems[index].title = title.trimmedFallback("새 인박스")
        inboxItems[index].note = note
        inboxItems[index].updatedAt = Date()
        touchRecent(id: item.id, type: .inbox, title: inboxItems[index].title)
        save()
    }

    func processInboxItem(_ item: InboxItem) {
        guard let index = inboxItems.firstIndex(where: { $0.id == item.id }) else { return }
        inboxItems[index].status = .processed
        inboxItems[index].updatedAt = Date()
        save()
    }

    func moveInboxItemToToday(_ item: InboxItem) {
        addTask(title: item.title, note: item.note, date: Date(), projectId: nil)
        processInboxItem(item)
    }

    func deleteInboxItem(_ item: InboxItem) {
        inboxItems.removeAll { $0.id == item.id }
        recents.removeAll { $0.itemId == item.id }
        save()
    }

    func addTask(title: String, note: String, date: Date, projectId: UUID?) {
        let task = Task(title: title.trimmedFallback("새 작업"), note: note, date: DateUtils.startOfDay(date), projectId: projectId)
        if let projectId, let projectIndex = projects.firstIndex(where: { $0.id == projectId }) {
            projects[projectIndex].tasks.insert(task, at: 0)
            projects[projectIndex].updatedAt = Date()
            touchRecent(id: projectId, type: .project, title: projects[projectIndex].title)
        } else {
            tasks.insert(task, at: 0)
            touchRecent(id: task.id, type: .task, title: task.title)
        }
        save()
    }

    func updateTask(_ task: Task, title: String, note: String, date: Date) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = title.trimmedFallback("새 작업")
            tasks[index].note = note
            tasks[index].date = DateUtils.startOfDay(date)
            tasks[index].updatedAt = Date()
        } else if let projectIndex = projects.firstIndex(where: { project in project.tasks.contains { $0.id == task.id } }), let taskIndex = projects[projectIndex].tasks.firstIndex(where: { $0.id == task.id }) {
            projects[projectIndex].tasks[taskIndex].title = title.trimmedFallback("새 작업")
            projects[projectIndex].tasks[taskIndex].note = note
            projects[projectIndex].tasks[taskIndex].date = DateUtils.startOfDay(date)
            projects[projectIndex].tasks[taskIndex].updatedAt = Date()
            projects[projectIndex].updatedAt = Date()
        }
        save()
    }

    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].status = tasks[index].status == .done ? .todo : .done
            tasks[index].updatedAt = Date()
        } else if let projectIndex = projects.firstIndex(where: { project in project.tasks.contains { $0.id == task.id } }), let taskIndex = projects[projectIndex].tasks.firstIndex(where: { $0.id == task.id }) {
            projects[projectIndex].tasks[taskIndex].status = projects[projectIndex].tasks[taskIndex].status == .done ? .todo : .done
            projects[projectIndex].tasks[taskIndex].updatedAt = Date()
            projects[projectIndex].updatedAt = Date()
        }
        save()
    }

    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        for index in projects.indices { projects[index].tasks.removeAll { $0.id == task.id } }
        recents.removeAll { $0.itemId == task.id }
        save()
    }

    func addTimeBlock(title: String, start: Date, end: Date, date: Date, type: TimeBlockType, projectId: UUID?, note: String?) {
        let block = TimeBlock(title: title.trimmedFallback("새 타임블록"), start: start, end: max(end, start.addingTimeInterval(1800)), date: DateUtils.startOfDay(date), type: type, projectId: projectId, note: note)
        timeBlocks.append(block)
        save()
    }

    func deleteTimeBlock(_ block: TimeBlock) {
        timeBlocks.removeAll { $0.id == block.id }
        save()
    }

    func addProject(title: String, description: String, status: ProjectStatus) {
        let project = Project(title: title.trimmedFallback("새 프로젝트"), description: description, status: status)
        projects.insert(project, at: 0)
        touchRecent(id: project.id, type: .project, title: project.title)
        save()
    }

    func updateProject(_ project: Project, title: String, description: String, status: ProjectStatus) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index].title = title.trimmedFallback("새 프로젝트")
        projects[index].description = description
        projects[index].status = status
        projects[index].updatedAt = Date()
        touchRecent(id: project.id, type: .project, title: projects[index].title)
        save()
    }

    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        tasks = tasks.map { task in
            var copy = task
            if copy.projectId == project.id { copy.projectId = nil }
            return copy
        }
        recents.removeAll { $0.itemId == project.id }
        save()
    }

    func addProjectWidget(projectId: UUID, type: ProjectWidgetType, title: String, content: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        let items = type == .checklist ? [ChecklistItem(title: "첫 항목")] : nil
        let widget = ProjectWidget(type: type, title: title.trimmedFallback(type.label), content: content, items: items)
        projects[index].widgets.append(widget)
        projects[index].updatedAt = Date()
        save()
    }

    func toggleProjectChecklistItem(projectId: UUID, widgetId: UUID, itemId: UUID) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }), let widgetIndex = projects[projectIndex].widgets.firstIndex(where: { $0.id == widgetId }), var items = projects[projectIndex].widgets[widgetIndex].items, let itemIndex = items.firstIndex(where: { $0.id == itemId }) else { return }
        items[itemIndex].isDone.toggle()
        projects[projectIndex].widgets[widgetIndex].items = items
        projects[projectIndex].updatedAt = Date()
        save()
    }

    func addProjectLog(projectId: UUID, content: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        projects[index].logs.insert(ProjectLog(content: content.trimmedFallback("새 기록")), at: 0)
        projects[index].updatedAt = Date()
        save()
    }

    func addMoodLog(moodScore: Int, energyScore: Int, note: String) {
        let today = DateUtils.startOfDay(Date())
        if let index = moodLogs.firstIndex(where: { DateUtils.isSameDay($0.date, today) }) {
            moodLogs[index].moodScore = moodScore
            moodLogs[index].energyScore = energyScore
            moodLogs[index].note = note
        } else {
            moodLogs.insert(MoodLog(date: today, moodScore: moodScore, energyScore: energyScore, note: note), at: 0)
        }
        save()
    }

    func saveReview(date: Date, completedSummary: String, missedSummary: String, reflection: String, refineNext: String) {
        let day = DateUtils.startOfDay(date)
        if let index = reviews.firstIndex(where: { DateUtils.isSameDay($0.date, day) }) {
            reviews[index].completedSummary = completedSummary
            reviews[index].missedSummary = missedSummary
            reviews[index].reflection = reflection
            reviews[index].refineNext = refineNext
            touchRecent(id: reviews[index].id, type: .review, title: "리뷰 \(DateUtils.dayFormatter.string(from: day))")
        } else {
            let review = Review(date: day, completedSummary: completedSummary, missedSummary: missedSummary, reflection: reflection, refineNext: refineNext)
            reviews.insert(review, at: 0)
            touchRecent(id: review.id, type: .review, title: "리뷰 \(DateUtils.dayFormatter.string(from: day))")
        }
        save()
    }

    func tasks(on date: Date) -> [Task] {
        let dayTasks = tasks.filter { DateUtils.isSameDay($0.date, date) }
        let projectTasks = projects.flatMap(\.tasks).filter { DateUtils.isSameDay($0.date, date) }
        return (dayTasks + projectTasks).sorted { $0.createdAt > $1.createdAt }
    }

    func timeBlocks(on date: Date) -> [TimeBlock] {
        timeBlocks.filter { DateUtils.isSameDay($0.date, date) }.sorted { $0.start < $1.start }
    }

    func activeProjects() -> [Project] { projects.filter { $0.status == .active } }

    func recentInboxItems(limit: Int = 4) -> [InboxItem] {
        Array(inboxItems.sorted { $0.createdAt > $1.createdAt }.prefix(limit))
    }

    private func apply(_ data: AppData) {
        inboxItems = data.inboxItems
        tasks = data.tasks
        timeBlocks = data.timeBlocks
        projects = data.projects
        moodLogs = data.moodLogs
        reviews = data.reviews
        recents = data.recents
    }

    private func touchRecent(id: UUID, type: RecentType, title: String) {
        recents.removeAll { $0.itemId == id }
        recents.insert(RecentItem(itemId: id, type: type, title: title), at: 0)
        recents = Array(recents.prefix(8))
    }
}

private extension String {
    func trimmedFallback(_ fallback: String) -> String {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? fallback : value
    }
}
