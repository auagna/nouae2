import Foundation

enum SeedData {
    static func make() -> AppData {
        let today = DateUtils.startOfDay(Date())
        let designProjectId = UUID()
        let programProjectId = UUID()

        let tasks = [
            Task(title: "오늘의 핵심 목표 정리", note: "집중 문장 하나로 압축하기", date: today),
            Task(title: "운동 30분", note: "가볍게 시작", date: today)
        ]

        let timeBlocks = [
            TimeBlock(
                title: "집중 작업",
                start: DateUtils.hourDate(day: today, hour: 10),
                end: DateUtils.hourDate(day: today, hour: 12),
                date: today,
                type: .timeBlock,
                note: "방해 요소 줄이기"
            ),
            TimeBlock(
                title: "저녁 리뷰",
                start: DateUtils.hourDate(day: today, hour: 21),
                end: DateUtils.hourDate(day: today, hour: 21, minute: 30),
                date: today,
                type: .routine,
                note: nil
            )
        ]

        let projects = [
            Project(
                id: designProjectId,
                title: "데일리 디자인",
                description: "매일 하나의 작은 화면을 설계하고 기록한다.",
                status: .active,
                tasks: [Task(title: "오늘의 레퍼런스 3개 수집", date: today, projectId: designProjectId)],
                widgets: [ProjectWidget(type: .memo, title: "방향", content: "작게 만들고 꾸준히 축적하기", items: nil)]
            ),
            Project(
                id: programProjectId,
                title: "1일 1프로그램 제작",
                description: "매일 실행 가능한 작은 도구를 만든다.",
                status: .active,
                tasks: [Task(title: "아이디어 후보 5개 적기", date: today, projectId: programProjectId)],
                widgets: [ProjectWidget(type: .checklist, title: "제작 루틴", content: "", items: [
                    ChecklistItem(title: "문제 정의"),
                    ChecklistItem(title: "작은 기능 완성"),
                    ChecklistItem(title: "기록")
                ])]
            ),
            Project(title: "운동", description: "체력과 컨디션을 안정적으로 관리한다.", status: .active),
            Project(title: "포트폴리오", description: "작업물을 정리하고 보여줄 형태로 다듬는다.", status: .paused)
        ]

        let inbox = [
            InboxItem(title: "다음 주 계획 재정리", note: "프로젝트별로 시간 배치하기"),
            InboxItem(title: "읽을 글 저장", note: "생산성 시스템 관련 아티클")
        ]

        let mood = [MoodLog(date: today, moodScore: 4, energyScore: 3, note: "차분하게 시작")]

        let recents = [
            RecentItem(itemId: projects[0].id, type: .project, title: projects[0].title),
            RecentItem(itemId: inbox[0].id, type: .inbox, title: inbox[0].title)
        ]

        return AppData(
            inboxItems: inbox,
            tasks: tasks,
            timeBlocks: timeBlocks,
            projects: projects,
            moodLogs: mood,
            reviews: [],
            recents: recents
        )
    }
}
