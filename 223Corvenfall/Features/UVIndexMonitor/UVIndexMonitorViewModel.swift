import Combine
import Foundation
import SwiftUI

@MainActor
final class UVIndexMonitorViewModel: ObservableObject {
    @Published var currentUVLevel: Int = 0
    @Published var showAlertSheet = false
    @Published var showSuccessHighlight = false
    @Published var showCheckmark = false
    @Published var lastUpdated: Date?

    private var timer: AnyCancellable?
    private weak var store: AppStorageStore?
    private var isSceneActive = true

    var recentHistory: [UVHistoryEntry] {
        Array((store?.uvIndexHistory ?? []).prefix(7))
    }

    var safeWindowLines: [String] {
        UVSimulator.safeWindowLines()
    }

    func configure(store: AppStorageStore, scenePhase: ScenePhase) {
        self.store = store
        updateScenePhase(scenePhase)
        refreshUVLevel(recordCheck: false)
    }

    func updateScenePhase(_ phase: ScenePhase) {
        isSceneActive = phase == .active
        timer?.cancel()

        guard isSceneActive else { return }

        timer = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshUVLevel(recordCheck: false)
            }
    }

    func refreshUVLevel(recordCheck: Bool) {
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
        refreshUVLevel(recordCheck: true)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCheckmark = true
        }
        FeedbackHelper.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showCheckmark = false
        }
    }

    func openAlertSettings() {
        FeedbackHelper.lightTap()
        showAlertSheet = true
    }

    func onAlertSaved() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccessHighlight = true
        }
        FeedbackHelper.alertSet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.showSuccessHighlight = false
        }
    }

    func deleteEntry(_ entry: UVHistoryEntry) {
        store?.deleteHistoryEntry(entry)
    }
}
