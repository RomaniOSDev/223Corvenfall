import SwiftUI

struct AchievementTileCell: View {
    let achievement: AchievementDefinition
    let unlocked: Bool
    var progressText: String?

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        unlocked
                            ? AppGradients.selectedSegment
                            : LinearGradient(
                                colors: [
                                    Color("AppTextSecondary").opacity(0.15),
                                    Color("AppTextSecondary").opacity(0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(unlocked ? Color("AppBackground") : Color("AppTextSecondary"))

                if unlocked {
                    Circle()
                        .stroke(Color("AppAccent").opacity(0.7), lineWidth: 2)
                        .frame(width: 52, height: 52)
                }
            }

            Text(achievement.title)
                .font(.caption.bold())
                .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            if let progressText, !unlocked {
                Text(progressText)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color("AppAccent"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 148)
        .appInset(cornerRadius: 16)
        .overlay {
            if unlocked {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color("AppAccent").opacity(0.4), lineWidth: 1)
            }
        }
    }
}
