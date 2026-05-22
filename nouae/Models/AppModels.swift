import Foundation

enum InboxStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case raw
    case processed

    var id: String { rawValue }
    var label: String { self == .raw ? "미처리" : "처리됨" }
}

enum TaskStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case todo
    case done

    var id: String { rawValue }
    var label: String { self == .todo ? "진행 전" : "완료" }
}

enum TimeBlockType: String, Codable, CaseIterable, Identifiable, Hashable {
    case task
    case timeBlock
    case projectMilestone
    case routine

    var id: String { rawValue }
    var label: String {
        switch self {
        case .task: return "작업"
        case .timeBlock: return "타임블록"
        case .projectMilestone: return "마일스톤"
        case .routine: return "루틴"
        }
    }
}

enum ProjectStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case active
    case paused
    case completed

    var id: String { rawValue }
    var label: String {
        switch self {
        case .active: return "진행 중"
        case .paused: return "보류"
        case .completed: return "완료"
        }
    }
}

enum ProjectWidgetType: String, Codable, CaseIterable, Identifiable, Hashable {
    case memo
    case checklist

    var id: String { rawValue }
    var label: String { self == .memo ? "메모" : "체크리스트" }
}

enum RecentType: String, Codable, Hashable {
    case inbox
    case task
    case project
    case note
    case review
}

struct InboxItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String
    var status: InboxStatus = .raw
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct Task: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String = ""
    var status: TaskStatus = .todo
    var date: Date = Date()
    var projectId: UUID?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct TimeBlock: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var start: Date
    var end: Date
    var date: Date
    var type: TimeBlockType = .timeBlock
    var projectId: UUID?
    var note: String?
}

struct ChecklistItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
}

struct ProjectWidget: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var type: ProjectWidgetType
    var title: String
    var content: String
    var items: [ChecklistItem]?
}

struct ProjectLog: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var content: String
}

struct Project: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var status: ProjectStatus = .active
    var tasks: [Task] = []
    var widgets: [ProjectWidget] = []
    var logs: [ProjectLog] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct MoodLog: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var moodScore: Int
    var energyScore: Int
    var note: String
}

struct Review: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var completedSummary: String
    var missedSummary: String
    var reflection: String
    var refineNext: String
}

struct RecentItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var itemId: UUID
    var type: RecentType
    var title: String
    var date: Date = Date()
}

struct AppData: Codable {
    var inboxItems: [InboxItem]
    var tasks: [Task]
    var timeBlocks: [TimeBlock]
    var projects: [Project]
    var moodLogs: [MoodLog]
    var reviews: [Review]
    var recents: [RecentItem]
}
