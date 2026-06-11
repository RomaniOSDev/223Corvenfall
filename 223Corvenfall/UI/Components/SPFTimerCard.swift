import SwiftUI

struct SPFTimerCard: View {
    @EnvironmentObject private var store: AppStorageStore
    @ObservedObject var timerManager: SPFTimerManager

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "drop.fill",
                    title: "SPF Timer",
                    subtitle: timerManager.isTimerActive ? "Protection window active" : "Track reapplication",
                    trailing: timerManager.isTimerActive
                        ? SPFTimerManager.formattedCountdown(seconds: timerManager.remainingSeconds)
                        : nil
                )

                if timerManager.isTimerActive {
                    ProgressView(value: progressValue, total: 1)
                        .tint(Color("AppAccent"))
                        .scaleEffect(y: 1.4)

                    Text("Reapply sunscreen when the timer ends.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    Text("Start a \(store.spfTimerDurationMinutes)-minute countdown after applying sunscreen.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                AppPrimaryButton(
                    title: timerManager.isTimerActive ? "Reapply Sunscreen" : "Applied Sunscreen",
                    icon: "drop.fill"
                ) {
                    timerManager.applySunscreen(store: store)
                }
            }
        }
    }

    private var progressValue: Double {
        let total = Double(store.spfTimerDurationMinutes * 60)
        guard total > 0, timerManager.isTimerActive else { return 0 }
        return Double(timerManager.remainingSeconds) / total
    }
}
