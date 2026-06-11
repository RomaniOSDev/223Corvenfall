import Combine
import Foundation
import SwiftUI

@MainActor
final class SPFTimerManager: ObservableObject {
    static let shared = SPFTimerManager()

    @Published var remainingSeconds: Int = 0
    @Published var isTimerActive = false
    @Published var showReapplyReminder = false

    private var countdownTimer: AnyCancellable?
    private weak var store: AppStorageStore?
    private var isSceneActive = true

    private init() {}

    func configure(store: AppStorageStore, scenePhase: ScenePhase) {
        self.store = store
        updateScenePhase(scenePhase)
        refreshState()
    }

    func updateScenePhase(_ phase: ScenePhase) {
        let wasInactive = !isSceneActive
        isSceneActive = phase == .active

        if phase == .active {
            if wasInactive {
                checkExpiredReminder()
            }
            startCountdownTimerIfNeeded()
        } else {
            countdownTimer?.cancel()
        }
    }

    func applySunscreen(store: AppStorageStore) {
        let duration = store.spfTimerDurationMinutes
        store.spfTimerEndsAt = Date().addingTimeInterval(TimeInterval(duration * 60))
        store.spfReminderPending = false
        self.store = store
        FeedbackHelper.mediumTap()
        FeedbackHelper.success()
        refreshState()
        startCountdownTimerIfNeeded()
    }

    func dismissReminder() {
        showReapplyReminder = false
        store?.spfReminderPending = false
        store?.spfTimerEndsAt = nil
        refreshState()
        FeedbackHelper.lightTap()
    }

    func reapply() {
        guard let store else { return }
        showReapplyReminder = false
        applySunscreen(store: store)
    }

    private func checkExpiredReminder() {
        guard let store, let endsAt = store.spfTimerEndsAt else { return }
        if endsAt <= Date(), store.spfReminderPending || !showReapplyReminder {
            store.spfReminderPending = true
            showReapplyReminder = true
            FeedbackHelper.warning()
            isTimerActive = false
            remainingSeconds = 0
        }
    }

    private func refreshState() {
        guard let endsAt = store?.spfTimerEndsAt else {
            isTimerActive = false
            remainingSeconds = 0
            return
        }

        let secondsLeft = Int(endsAt.timeIntervalSinceNow)
        if secondsLeft > 0 {
            isTimerActive = true
            remainingSeconds = secondsLeft
        } else {
            isTimerActive = false
            remainingSeconds = 0
            if store?.spfReminderPending == true {
                showReapplyReminder = true
            }
        }
    }

    private func startCountdownTimerIfNeeded() {
        countdownTimer?.cancel()
        guard isSceneActive, store?.spfTimerEndsAt != nil else { return }

        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        refreshState()
        if let endsAt = store?.spfTimerEndsAt, endsAt <= Date(), !(store?.spfReminderPending ?? false) {
            store?.spfReminderPending = true
            showReapplyReminder = true
            FeedbackHelper.warning()
            countdownTimer?.cancel()
        }
    }

    static func formattedCountdown(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}
