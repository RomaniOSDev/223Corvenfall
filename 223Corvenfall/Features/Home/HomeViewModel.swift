import Combine
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var currentUVLevel: Int = 0
    @Published var lastUpdated: Date?
    @Published var showAlertSheet = false
    @Published var showCheckmark = false
    @Published var showAddRecord = false

    private var timer: AnyCancellable?
    private weak var store: AppStorageStore?
    private var isSceneActive = true

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    var safeWindowLines: [String] {
        UVSimulator.safeWindowLines()
    }

    var exposureProgress: Double {
        guard let store, store.dailyExposureGoalMinutes > 0 else { return 0 }
        return min(1, Double(store.todayExposureMinutes) / Double(store.dailyExposureGoalMinutes))
    }

    var unlockedAchievements: Int {
        AchievementDefinition.all.filter { $0.isUnlocked(store: store ?? AppStorageStore.shared) }.count
    }

    var protectionTip: ProtectionTip? {
        UVProtectionAdvice.tips(for: currentUVLevel).first
    }

    func configure(store: AppStorageStore, scenePhase: ScenePhase) {
        self.store = store
        updateScenePhase(scenePhase)
        refreshUV(recordCheck: false)
    }

    func updateScenePhase(_ phase: ScenePhase) {
        isSceneActive = phase == .active
        timer?.cancel()
        guard isSceneActive else { return }

        timer = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshUV(recordCheck: false)
            }
    }

    func refreshUV(recordCheck: Bool) {
        let level = UVSimulator.currentUVLevel()
        currentUVLevel = level
        lastUpdated = Date()

        if recordCheck {
            store?.recordUVCheck(level: level)
            store?.completeSession()
        }
    }

    func checkNow() {
        FeedbackHelper.mediumTap()
        refreshUV(recordCheck: true)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCheckmark = true
        }
        FeedbackHelper.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showCheckmark = false
        }
    }

    func openAlerts() {
        FeedbackHelper.lightTap()
        showAlertSheet = true
    }

    func openAddRecord() {
        FeedbackHelper.lightTap()
        showAddRecord = true
    }
}
