import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStorageStore.shared
    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var sessionTracker = SessionTracker()
    @StateObject private var spfTimerManager = SPFTimerManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if store.hasSeenOnboarding {
                    MainTabContainerView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(store)
            .environmentObject(spfTimerManager)

            if achievementManager.showBanner, let achievement = achievementManager.bannerAchievement {
                AchievementBannerView(achievement: achievement)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            sessionTracker.start(store: store, scenePhase: scenePhase)
            spfTimerManager.configure(store: store, scenePhase: scenePhase)
            achievementManager.evaluate(store: store)
        }
        .onChange(of: scenePhase) { phase in
            sessionTracker.updateScenePhase(phase)
            spfTimerManager.updateScenePhase(phase)
        }
        .alert("Time to Reapply SPF", isPresented: $spfTimerManager.showReapplyReminder) {
            Button("Reapply") {
                spfTimerManager.reapply()
            }
            Button("Dismiss", role: .cancel) {
                spfTimerManager.dismissReminder()
            }
        } message: {
            Text("Your sunscreen protection window has ended. Reapply for continued coverage.")
        }
    }
}

#Preview {
    ContentView()
}
