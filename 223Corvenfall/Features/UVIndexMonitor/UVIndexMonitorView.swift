import SwiftUI

struct UVIndexMonitorView: View {
    @EnvironmentObject private var store: AppStorageStore
    @EnvironmentObject private var spfTimerManager: SPFTimerManager
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = UVIndexMonitorViewModel()

    var body: some View {
        ZStack {
            Color.clear

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    gaugeSection
                    SafeWindowCard(lines: viewModel.safeWindowLines)
                    SPFTimerCard(timerManager: spfTimerManager)
                    DailyExposureLimitCard()
                    historySection
                    AppPrimaryButton(
                        title: "Set Alert",
                        icon: "bell.badge.fill",
                        highlighted: viewModel.showSuccessHighlight
                    ) {
                        viewModel.openAlertSettings()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            SuccessCheckmarkOverlay(isVisible: $viewModel.showCheckmark)
        }
        .appScreenStyle(title: "UV Index Monitor")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.checkNow()
                } label: {
                    Label("Check", systemImage: "arrow.clockwise")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppPrimary"))
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
        }
        .sheet(isPresented: $viewModel.showAlertSheet) {
            AlertSettingsSheet(onSaved: viewModel.onAlertSaved)
                .environmentObject(store)
        }
        .onAppear {
            viewModel.configure(store: store, scenePhase: scenePhase)
            spfTimerManager.configure(store: store, scenePhase: scenePhase)
        }
        .onChange(of: scenePhase) { phase in
            viewModel.updateScenePhase(phase)
            spfTimerManager.updateScenePhase(phase)
        }
    }

    private var gaugeSection: some View {
        AppCard {
            VStack(spacing: 16) {
                AppSectionHeader(
                    icon: "sun.max.fill",
                    title: "Current UV Level",
                    subtitle: store.isAlertEnabled
                        ? "Alert at UV \(store.alertThreshold)+"
                        : "Alerts off",
                    trailing: UVSimulator.uvLabel(for: viewModel.currentUVLevel)
                )

                EnhancedUVGauge(
                    level: viewModel.currentUVLevel,
                    lastUpdated: viewModel.lastUpdated
                )

                UVProtectionTipsCard(uvLevel: viewModel.currentUVLevel)
            }
        }
    }

    private var historySection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "chart.bar.fill",
                    title: "Historical Trends",
                    subtitle: "Last 7 days",
                    trailing: viewModel.recentHistory.isEmpty ? nil : "\(viewModel.recentHistory.count) days"
                )

                if viewModel.recentHistory.isEmpty {
                    AppEmptyState(
                        icon: "sun.max.fill",
                        title: "Track your first UV Level here!",
                        message: "Tap Check to log today's UV index.",
                        actionTitle: "Check Now"
                    ) {
                        viewModel.checkNow()
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            ForEach(viewModel.recentHistory) { entry in
                                UVHistoryPillCell(
                                    dayInitial: UVSimulator.dayInitial(for: entry.day),
                                    uvLevel: entry.uvLevel,
                                    isToday: Calendar.current.isDateInToday(entry.day)
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    List {
                        ForEach(viewModel.recentHistory) { entry in
                            IconValueCell(
                                icon: "calendar",
                                title: formattedDay(entry.day),
                                subtitle: UVSimulator.uvLabel(for: entry.uvLevel),
                                valueBadgeLevel: entry.uvLevel,
                                showChevron: false
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteEntry(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .frame(height: CGFloat(viewModel.recentHistory.count) * 76)
                }
            }
        }
    }

    private func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
