import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_check",
            title: "First Check",
            description: "Checked the UV index once.",
            iconName: "sun.max"
        ),
        AchievementDefinition(
            id: "daily_watcher",
            title: "Daily Watcher",
            description: "Monitored the UV index daily for a week.",
            iconName: "calendar"
        ),
        AchievementDefinition(
            id: "sun_savvy",
            title: "Sun Savvy",
            description: "Received alerts for ten high-UV days.",
            iconName: "bell.badge"
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 items.",
            iconName: "bolt.fill"
        ),
        AchievementDefinition(
            id: "active_user",
            title: "Active User",
            description: "Completed 10 sessions.",
            iconName: "figure.walk"
        ),
        AchievementDefinition(
            id: "dedicated_user",
            title: "Dedicated User",
            description: "Completed 50 sessions.",
            iconName: "star.fill"
        ),
        AchievementDefinition(
            id: "three_day_streak",
            title: "Three-Day Streak",
            description: "Used the app 3 days in a row.",
            iconName: "flame.fill"
        ),
        AchievementDefinition(
            id: "time_invested",
            title: "Time Invested",
            description: "Spent 60 minutes total in the app.",
            iconName: "clock.fill"
        )
    ]

    func isUnlocked(store: AppStorageStore) -> Bool {
        switch id {
        case "first_check":
            return store.itemsCreated >= 1
        case "daily_watcher":
            return store.streakDays >= 7
        case "sun_savvy":
            return store.itemsCreated >= 10
        case "power_user":
            return store.itemsCreated >= 50
        case "active_user":
            return store.totalSessionsCompleted >= 10
        case "dedicated_user":
            return store.totalSessionsCompleted >= 50
        case "three_day_streak":
            return store.streakDays >= 3
        case "time_invested":
            return store.totalMinutesUsed >= 60
        default:
            return false
        }
    }

    func progressText(store: AppStorageStore) -> String? {
        guard !isUnlocked(store: store) else { return nil }
        switch id {
        case "first_check":
            return "\(min(store.itemsCreated, 1))/1 checks"
        case "daily_watcher":
            return "\(min(store.streakDays, 7))/7 days"
        case "sun_savvy":
            return "\(min(store.itemsCreated, 10))/10 items"
        case "power_user":
            return "\(min(store.itemsCreated, 50))/50 items"
        case "active_user":
            return "\(min(store.totalSessionsCompleted, 10))/10 sessions"
        case "dedicated_user":
            return "\(min(store.totalSessionsCompleted, 50))/50 sessions"
        case "three_day_streak":
            return "\(min(store.streakDays, 3))/3 days"
        case "time_invested":
            return "\(min(store.totalMinutesUsed, 60))/60 min"
        default:
            return nil
        }
    }
}
