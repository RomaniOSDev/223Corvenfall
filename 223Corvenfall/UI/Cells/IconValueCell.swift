import SwiftUI

struct IconValueCell: View {
    let icon: String
    let title: String
    var subtitle: String?
    var value: String?
    var valueBadgeLevel: Int?
    var showChevron: Bool = true
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Group {
                    if isDestructive {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color("AppAccent").opacity(0.18))
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppGradients.selectedSegment)
                    }
                }
                .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isDestructive ? Color("AppAccent") : Color("AppBackground"))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isDestructive ? Color("AppAccent") : Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }

            Spacer(minLength: 8)

            if let level = valueBadgeLevel {
                UVLevelBadge(level: level)
            } else if let value {
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 68)
        .appInset(cornerRadius: 14)
    }
}
