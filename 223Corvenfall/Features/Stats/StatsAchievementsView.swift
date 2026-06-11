import SwiftUI

struct StatsAchievementsView: View {
    @EnvironmentObject private var store: AppStorageStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { $0.isUnlocked(store: store) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack{
                AppScaffoldBackground()
        
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    summarySection
                    achievementsSection
                }
                .padding()
            }
            .padding(.bottom, 60)
            .appScreenStyle(title: "Stats & Achievements")
        }
        }
    }

    private var summarySection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "chart.pie.fill",
                    title: "Summary",
                    subtitle: "Your activity at a glance",
                    trailing: "\(unlockedCount)/8 badges"
                )

                LazyVGrid(columns: columns, spacing: 10) {
                    MetricTileCell(
                        icon: "square.and.pencil",
                        title: "Entries",
                        value: "\(store.itemsCreated)",
                        footnote: store.itemsCreated > 0 ? "Keep logging" : nil
                    )
                    MetricTileCell(
                        icon: "checkmark.circle.fill",
                        title: "Sessions",
                        value: "\(store.totalSessionsCompleted)"
                    )
                    MetricTileCell(
                        icon: "flame.fill",
                        title: "Streak",
                        value: "\(store.streakDays)",
                        footnote: store.streakDays > 0 ? "days in a row" : nil
                    )
                    MetricTileCell(
                        icon: "clock.fill",
                        title: "Time",
                        value: "\(store.totalMinutesUsed)",
                        footnote: "minutes total"
                    )
                }
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                icon: "rosette",
                title: "Achievements",
                subtitle: "Unlock badges through real actions"
            )
            .padding(.horizontal, 4)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AchievementDefinition.all) { achievement in
                    AchievementTileCell(
                        achievement: achievement,
                        unlocked: achievement.isUnlocked(store: store),
                        progressText: achievement.progressText(store: store)
                    )
                }
            }
        }
    }
}
