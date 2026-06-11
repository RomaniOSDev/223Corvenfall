import SwiftUI

struct MainTabContainerView: View {
    @StateObject private var tabRouter = AppTabRouter()

    var body: some View {
        ZStack(alignment: .bottom) {
           

            
                Group {
                    switch tabRouter.selectedTab {
                    case .home:
                        HomeView()
                    case .history:
                        HistoryContainerView()
                    case .stats:
                        StatsAchievementsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $tabRouter.selectedTab)
            
        }
        .environmentObject(tabRouter)
    }
}
