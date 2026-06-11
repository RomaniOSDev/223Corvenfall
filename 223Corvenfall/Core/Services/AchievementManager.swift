import Combine
import Foundation
import SwiftUI

final class AchievementManager: ObservableObject {
    static let shared = AchievementManager()

    @Published var bannerAchievement: AchievementDefinition?
    @Published var showBanner = false

    private var queue: [AchievementDefinition] = []
    private var isShowing = false

    private init() {}

    func evaluate(store: AppStorageStore) {
        var newlyUnlocked: [AchievementDefinition] = []

        for achievement in AchievementDefinition.all {
            guard store.achievementsUnlocked[achievement.id] == nil else { continue }
            if achievement.isUnlocked(store: store) {
                store.achievementsUnlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }

        guard !newlyUnlocked.isEmpty else { return }

        for achievement in newlyUnlocked {
            queue.append(achievement)
        }
        showNextIfNeeded()
    }

    private func showNextIfNeeded() {
        guard !isShowing, let next = queue.first else { return }
        queue.removeFirst()
        isShowing = true
        bannerAchievement = next
        FeedbackHelper.success()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showBanner = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showBanner = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                guard let self else { return }
                self.isShowing = false
                self.bannerAchievement = nil
                self.showNextIfNeeded()
            }
        }
    }
}
