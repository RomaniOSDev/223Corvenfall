import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case history
    case stats
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .history: return "History"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .history: return "chart.line.uptrend.xyaxis"
        case .stats: return "rosette"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @State private var pressedTab: AppTab?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppGradients.cardSurface)
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppGradients.topHighlight)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color("AppAccent").opacity(0.22), lineWidth: 1)
        }
        .compositingGroup()
        .shadow(
            color: Color("AppBackground").opacity(AppElevationLevel.prominent.shadowOpacity),
            radius: AppElevationLevel.prominent.shadowRadius,
            y: -2
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        let isPressed = pressedTab == tab

        return Button {
            FeedbackHelper.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppGradients.selectedSegment)
                            .frame(width: 44, height: 32)
                            .compositingGroup()
                            .shadow(color: Color("AppBackground").opacity(0.22), radius: 4, y: 2)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
                }
                .frame(height: 32)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(isSelected ? Color("AppPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .scaleEffect(isPressed ? 0.94 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedTab = tab }
                .onEnded { _ in pressedTab = nil }
        )
    }
}
