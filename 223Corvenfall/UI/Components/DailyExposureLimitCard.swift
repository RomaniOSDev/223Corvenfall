import SwiftUI

struct DailyExposureLimitCard: View {
    @EnvironmentObject private var store: AppStorageStore

    private let goalOptions = [30, 60, 90]

    private var todayMinutes: Int { store.todayExposureMinutes }

    private var progress: Double {
        guard store.dailyExposureGoalMinutes > 0 else { return 0 }
        return min(1, Double(todayMinutes) / Double(store.dailyExposureGoalMinutes))
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "figure.walk",
                    title: "Daily Exposure Limit",
                    subtitle: "Based on logged exposure records",
                    trailing: "\(Int(progress * 100))%"
                )

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(todayMinutes)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("/ \(store.dailyExposureGoalMinutes) min")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color("AppBackground").opacity(0.45))
                        Capsule()
                            .fill(AppGradients.selectedSegment)
                            .frame(width: max(8, geo.size.width * progress))
                    }
                }
                .frame(height: 10)

                if progress >= 1 {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text("Daily limit reached — seek shade.")
                    }
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                }

                CustomSegmentedControl(
                    options: goalOptions,
                    title: { "\($0) min" },
                    selection: Binding(
                        get: { store.dailyExposureGoalMinutes },
                        set: { newValue in
                            store.dailyExposureGoalMinutes = newValue
                            store.registerMeaningfulAction()
                        }
                    )
                )
            }
        }
    }
}
