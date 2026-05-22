import SwiftUI

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case home
    case inbox
    case today
    case calendar
    case projects
    case review
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .inbox: return "Inbox"
        case .today: return "Today"
        case .calendar: return "Calendar"
        case .projects: return "Projects"
        case .review: return "Review"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "square.grid.2x2"
        case .inbox: return "tray"
        case .today: return "checklist"
        case .calendar: return "calendar"
        case .projects: return "folder"
        case .review: return "doc.text.magnifyingglass"
        case .settings: return "gearshape"
        }
    }
}

struct RootView: View {
    @State private var selection: AppSection? = .home

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            Group {
                switch selection ?? .home {
                case .home: HomeView()
                case .inbox: InboxView()
                case .today: TodayView()
                case .calendar: CalendarView()
                case .projects: ProjectsView()
                case .review: ReviewView()
                case .settings: SettingsView()
                }
            }
            .background(Color.nouBackground)
        }
    }
}
