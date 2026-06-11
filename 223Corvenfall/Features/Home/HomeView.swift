import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStorageStore
    @EnvironmentObject private var tabRouter: AppTabRouter
    @EnvironmentObject private var spfTimerManager: SPFTimerManager
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = HomeViewModel()

    private let widgetColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppScaffoldBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        heroBanner
                        widgetGrid
                        quickActions
                        monitorLink
                    }
                    .padding()
                }
                .padding(.bottom, 60)

                SuccessCheckmarkOverlay(isVisible: $viewModel.showCheckmark)
            }
            .appScreenStyle(title: "Home")
            .sheet(isPresented: $viewModel.showAlertSheet) {
                AlertSettingsSheet(onSaved: {
                    FeedbackHelper.alertSet()
                })
                .environmentObject(store)
            }
            .sheet(isPresented: $viewModel.showAddRecord) {
                AddUVRecordSheet(existingRecord: nil) { date, maxIndex, duration, _ in
                    store.uvRecords.append(UVRecord(date: date, maxIndex: maxIndex, exposureDuration: duration))
                    store.incrementItemCreated()
                    store.registerMeaningfulAction()
                    FeedbackHelper.confirmAdd()
                }
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
    }

    // MARK: - Hero

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 190)
                .clipped()

            AppGradients.heroOverlay

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.greeting)
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(viewModel.dateText)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))

                HStack(spacing: 8) {
                    UVLevelBadge(level: viewModel.currentUVLevel)
                    Text(UVSimulator.uvLabel(for: viewModel.currentUVLevel))
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .padding(18)
        }
        .frame(height: 190)
        .appImageFrame(cornerRadius: 22)
        .compositingGroup()
        .shadow(
            color: Color("AppBackground").opacity(AppElevationLevel.prominent.shadowOpacity),
            radius: AppElevationLevel.prominent.shadowRadius,
            y: AppElevationLevel.prominent.shadowYOffset
        )
    }

    // MARK: - Widgets

    private var widgetGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                icon: "square.grid.2x2.fill",
                title: "Dashboard",
                subtitle: "Your sun safety at a glance"
            )
            .padding(.horizontal, 2)

            LazyVGrid(columns: widgetColumns, spacing: 12) {
                uvWidget
                spfWidget
                exposureWidget
                safeWindowWidget
                protectionWidget
                achievementsWidget
            }
        }
    }

    private var uvWidget: some View {
        NavigationLink {
            UVIndexMonitorView()
        } label: {
            HomeWidgetTile(imageName: "HomeUVWidget", spanFullWidth: true) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("UV Index", systemImage: "sun.max.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(viewModel.currentUVLevel)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("/ 11")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    Text("Tap for full monitor")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .gridCellColumns(2)
    }

    private var spfWidget: some View {
        Button {
            spfTimerManager.applySunscreen(store: store)
        } label: {
            HomeWidgetTile {
                VStack(alignment: .leading, spacing: 10) {
                    Label("SPF Timer", systemImage: "drop.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))

                    if spfTimerManager.isTimerActive {
                        Text(SPFTimerManager.formattedCountdown(seconds: spfTimerManager.remainingSeconds))
                            .font(.title3.monospacedDigit().bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        ProgressView(
                            value: spfProgress,
                            total: 1
                        )
                        .tint(Color("AppAccent"))
                    } else {
                        Text("Tap to start")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("\(store.spfTimerDurationMinutes) min")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private var exposureWidget: some View {
        Button {
            tabRouter.open(.history)
        } label: {
            HomeWidgetTile {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Exposure", systemImage: "figure.walk")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))

                    Text("\(store.todayExposureMinutes)m")
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))

                    ProgressView(value: viewModel.exposureProgress)
                        .tint(Color("AppAccent"))

                    Text("Goal \(store.dailyExposureGoalMinutes)m")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private var safeWindowWidget: some View {
        NavigationLink {
            UVIndexMonitorView()
        } label: {
            HomeWidgetTile {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Safe Windows", systemImage: "clock.badge.checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))

                    if let first = viewModel.safeWindowLines.first {
                        Text(first)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    if viewModel.safeWindowLines.count > 1 {
                        Text("+\(viewModel.safeWindowLines.count - 1) more")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private var protectionWidget: some View {
        HomeWidgetTile(imageName: "HomeProtectionWidget") {
            VStack(alignment: .leading, spacing: 8) {
                Label("Protection", systemImage: "shield.lefthalf.filled")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))

                if let tip = viewModel.protectionTip {
                    Text(tip.text)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .gridCellColumns(2)
    }

    private var achievementsWidget: some View {
        Button {
            tabRouter.open(.stats)
        } label: {
            HomeWidgetTile {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Achievements", systemImage: "rosette")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(viewModel.unlockedAchievements)")
                            .font(.title.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("/ 8")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    HStack(spacing: 4) {
                        ForEach(0..<8, id: \.self) { index in
                            Circle()
                                .fill(
                                    index < viewModel.unlockedAchievements
                                        ? Color("AppAccent")
                                        : Color("AppTextSecondary").opacity(0.25)
                                )
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                icon: "bolt.fill",
                title: "Quick Actions",
                subtitle: "One tap to stay protected"
            )
            .padding(.horizontal, 2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    quickActionChip(title: "Check UV", icon: "arrow.clockwise") {
                        viewModel.checkNow()
                    }
                    quickActionChip(title: "Set Alert", icon: "bell.badge") {
                        viewModel.openAlerts()
                    }
                    quickActionChip(title: "Log Entry", icon: "plus.circle") {
                        viewModel.openAddRecord()
                    }
                    quickActionChip(title: "History", icon: "chart.line.uptrend.xyaxis") {
                        tabRouter.open(.history)
                    }
                }
            }
        }
    }

    private func quickActionChip(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.bold())
                Text(title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(Color("AppBackground"))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                ZStack {
                    Capsule(style: .continuous).fill(AppGradients.primaryButton)
                    Capsule(style: .continuous).fill(AppGradients.topHighlight)
                }
            }
            .compositingGroup()
            .shadow(color: Color("AppBackground").opacity(0.22), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }

    private var monitorLink: some View {
        NavigationLink {
            UVIndexMonitorView()
        } label: {
            AppCard {
                HStack(spacing: 14) {
                    Image(systemName: "gauge.with.needle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                        .frame(width: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Full UV Monitor")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("History, alerts, SPF timer & exposure limits")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var spfProgress: Double {
        let total = Double(store.spfTimerDurationMinutes * 60)
        guard total > 0, spfTimerManager.isTimerActive else { return 0 }
        return Double(spfTimerManager.remainingSeconds) / total
    }
}
