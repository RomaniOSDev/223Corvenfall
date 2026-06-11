import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack{
                AppScaffoldBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    statsSection
                    actionsSection
                    versionFooter
                }
                .padding()
            }
            .padding(.bottom, 60)
            .appScreenStyle(title: "Settings")
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    FeedbackHelper.lightTap()
                }
                Button("Reset", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("This will permanently delete all saved data and progress.")
            }
        }
        }
    }

    private var statsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "chart.bar.doc.horizontal.fill",
                    title: "Your Stats",
                    subtitle: "Local counters on this device"
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    MetricTileCell(icon: "tray.full.fill", title: "Total Entries", value: "\(store.itemsCreated)")
                    MetricTileCell(icon: "timer", title: "Minutes Used", value: "\(store.totalMinutesUsed)")
                }

                MetricTileCell(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(store.streakDays)",
                    footnote: "days"
                )
            }
        }
    }

    private var actionsSection: some View {
        AppCard(padding: 12) {
            VStack(spacing: 8) {
                Button {
                    FeedbackHelper.lightTap()
                    rateApp()
                } label: {
                    IconValueCell(
                        icon: "star.fill",
                        title: "Rate Us",
                        subtitle: "Enjoying the app? Leave a review",
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)

                Button {
                    FeedbackHelper.lightTap()
                    openLink(.privacyPolicy)
                } label: {
                    IconValueCell(
                        icon: "hand.raised.fill",
                        title: "Privacy",
                        subtitle: "Read our privacy policy",
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)

                Button {
                    FeedbackHelper.lightTap()
                    openLink(.termsOfService)
                } label: {
                    IconValueCell(
                        icon: "doc.text.fill",
                        title: "Terms",
                        subtitle: "Terms of service",
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)

                Button {
                    FeedbackHelper.lightTap()
                    showResetAlert = true
                } label: {
                    IconValueCell(
                        icon: "trash.fill",
                        title: "Reset All Data",
                        subtitle: "Clear all local progress",
                        showChevron: true,
                        isDestructive: true
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var versionFooter: some View {
        Text("Version \(appVersion)")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }

    private func openLink(_ link: AppExternalLinks) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func resetData() {
        FeedbackHelper.warning()
        store.resetAllData()
        NotificationCenter.default.post(name: .dataReset, object: nil)
        AchievementManager.shared.evaluate(store: store)
    }
}
