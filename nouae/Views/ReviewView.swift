import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var store: AppStore
    @State private var completedSummary = ""
    @State private var missedSummary = ""
    @State private var reflection = ""
    @State private var refineNext = ""

    private var todayTasks: [Task] { store.tasks(on: Date()) }
    private var completedTasks: [Task] { todayTasks.filter { $0.status == .done } }
    private var missedTasks: [Task] { todayTasks.filter { $0.status == .todo } }
    private var latestMood: MoodLog? { store.moodLogs.first { DateUtils.isSameDay($0.date, Date()) } }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 16)], spacing: 16) {
                CardView {
                    SectionHeader(title: "Completed Tasks")
                    if completedTasks.isEmpty { EmptyStateView(title: "완료 작업 없음", message: "오늘 완료된 작업이 아직 없습니다.") }
                    else { ForEach(completedTasks) { task in Label(task.title, systemImage: "checkmark.circle.fill").foregroundStyle(Color.nouAccent) } }
                }

                CardView {
                    SectionHeader(title: "Missed Tasks")
                    if missedTasks.isEmpty { EmptyStateView(title: "미완료 작업 없음", message: "오늘 남은 작업이 없습니다.") }
                    else { ForEach(missedTasks) { task in Label(task.title, systemImage: "circle").foregroundStyle(.secondary) } }
                }

                CardView {
                    SectionHeader(title: "Mood / Energy Log")
                    if let latestMood {
                        Text("기분 \(latestMood.moodScore) / 에너지 \(latestMood.energyScore)").font(.title3.weight(.semibold))
                        Text(latestMood.note.isEmpty ? "메모 없음" : latestMood.note).foregroundStyle(.secondary)
                    } else {
                        EmptyStateView(title: "상태 기록 없음", message: "Home에서 오늘 상태를 기록할 수 있습니다.")
                    }
                }

                CardView {
                    SectionHeader(title: "Weekly Summary")
                    let summary = weeklySummary()
                    Text("완료 \(summary.done) / 전체 \(summary.total)").font(.title3.weight(.semibold))
                    Text("리뷰 \(summary.reviews)개, 상태 기록 \(summary.moods)개").foregroundStyle(.secondary)
                }

                CardView {
                    SectionHeader(title: "Daily Review")
                    TextField("완료 요약", text: $completedSummary, axis: .vertical)
                    TextField("놓친 것", text: $missedSummary, axis: .vertical)
                    TextField("성찰 메모", text: $reflection, axis: .vertical)
                    TextField("내일 다듬을 것", text: $refineNext, axis: .vertical)
                    Button("리뷰 저장") {
                        store.saveReview(date: Date(), completedSummary: completedSummary, missedSummary: missedSummary, reflection: reflection, refineNext: refineNext)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.nouAccent)
                }

                CardView {
                    SectionHeader(title: "Saved Reviews")
                    if store.reviews.isEmpty {
                        EmptyStateView(title: "저장된 리뷰 없음", message: "하루를 닫으며 짧게 남겨보세요.")
                    } else {
                        ForEach(store.reviews.sorted { $0.date > $1.date }) { review in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(DateUtils.dayFormatter.string(from: review.date)).font(.headline)
                                if !review.reflection.isEmpty { Text(review.reflection).foregroundStyle(.secondary).lineLimit(3) }
                            }
                            Divider()
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("리뷰")
        .onAppear(perform: loadTodayReview)
    }

    private func loadTodayReview() {
        guard let review = store.reviews.first(where: { DateUtils.isSameDay($0.date, Date()) }) else { return }
        completedSummary = review.completedSummary
        missedSummary = review.missedSummary
        reflection = review.reflection
        refineNext = review.refineNext
    }

    private func weeklySummary() -> (done: Int, total: Int, reviews: Int, moods: Int) {
        let days = DateUtils.weekDays(containing: Date())
        let weekTasks = days.flatMap { store.tasks(on: $0) }
        let done = weekTasks.filter { $0.status == .done }.count
        let reviews = store.reviews.filter { review in days.contains { DateUtils.isSameDay($0, review.date) } }.count
        let moods = store.moodLogs.filter { mood in days.contains { DateUtils.isSameDay($0, mood.date) } }.count
        return (done, weekTasks.count, reviews, moods)
    }
}
