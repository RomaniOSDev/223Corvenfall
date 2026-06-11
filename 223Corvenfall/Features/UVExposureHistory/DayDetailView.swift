import SwiftUI

struct DayDetailView: View {
    let date: Date
    let maxUV: Float

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private var uvLevel: Int { Int(maxUV.rounded()) }

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    AppCard {
                        VStack(spacing: 16) {
                            AppSectionHeader(
                                icon: "calendar",
                                title: dateText,
                                subtitle: "Daily UV summary"
                            )
                            UVLevelBadge(level: uvLevel, style: .hero)
                        }
                    }

                    AppCard {
                        VStack(spacing: 10) {
                            detailRow(icon: "sun.max.fill", title: "Maximum UV Index", value: String(format: "%.1f", maxUV))
                            detailRow(icon: UVRiskStyle.icon(for: uvLevel), title: "Risk Level", value: UVSimulator.uvLabel(for: uvLevel))
                        }
                    }

                    AppCard {
                        UVProtectionTipsCard(uvLevel: uvLevel, embedded: false)
                    }
                }
                .padding(16)
            }
        }
        .appScreenStyle(title: "Day Details")
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("AppPrimary").opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundStyle(Color("AppPrimary"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(value)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("AppBackground").opacity(0.28))
        )
    }
}
