import Combine
import SwiftUI

final class SessionTracker: ObservableObject {
    @Published private(set) var isActive = true

    private var timer: AnyCancellable?
    private weak var store: AppStorageStore?

    func start(store: AppStorageStore, scenePhase: ScenePhase) {
        self.store = store
        updateTimer(for: scenePhase)
    }

    func updateScenePhase(_ phase: ScenePhase) {
        isActive = phase == .active
        updateTimer(for: phase)
    }

    private func updateTimer(for phase: ScenePhase) {
        timer?.cancel()
        guard phase == .active else { return }

        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.store?.addUsageMinute()
            }
    }
}
