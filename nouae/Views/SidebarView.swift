import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selection: AppSection?

    var body: some View {
        List(selection: $selection) {
            Section {
                ForEach(AppSection.allCases) { section in
                    Label(section.title, systemImage: section.systemImage)
                        .tag(section as AppSection?)
                }
            }

            Section("Recents") {
                if store.recents.isEmpty {
                    Text("최근 항목 없음")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.recents) { recent in
                        Button { selection = section(for: recent.type) } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(recent.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(label(for: recent.type))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("nou ae")
    }

    private func section(for type: RecentType) -> AppSection {
        switch type {
        case .inbox: return .inbox
        case .task: return .today
        case .project: return .projects
        case .note: return .home
        case .review: return .review
        }
    }

    private func label(for type: RecentType) -> String {
        switch type {
        case .inbox: return "인박스"
        case .task: return "작업"
        case .project: return "프로젝트"
        case .note: return "노트"
        case .review: return "리뷰"
        }
    }
}
