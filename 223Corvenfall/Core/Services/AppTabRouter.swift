import Combine
import Foundation

final class AppTabRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home

    func open(_ tab: AppTab) {
        FeedbackHelper.lightTap()
        selectedTab = tab
    }
}
