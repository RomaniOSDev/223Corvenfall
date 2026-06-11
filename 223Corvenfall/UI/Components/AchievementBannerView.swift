import SwiftUI

struct AchievementBannerView: View {
    let achievement: AchievementDefinition

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppGradients.selectedSegment)
                    .frame(width: 44, height: 44)
                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(Color("AppBackground"))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Achievement Unlocked")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()

            Image(systemName: "star.fill")
                .foregroundStyle(Color("AppAccent"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .appElevated(.prominent, cornerRadius: 16)
        .padding(.horizontal, 16)
    }
}
