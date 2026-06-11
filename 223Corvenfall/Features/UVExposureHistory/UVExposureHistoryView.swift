import Charts
import SwiftUI

struct UVExposureHistoryView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = UVExposureHistoryViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppScaffoldBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        chartSection
                        listSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 80)
                }

                AppFloatingButton(icon: "slider.horizontal.3", title: "Log Settings") {
                    viewModel.openLogSettings()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 16)
            }
            .appScreenStyle(title: "UV Exposure History")
            .navigationDestination(for: UVExposureHistoryViewModel.DayEntry.self) { entry in
                DayDetailView(date: entry.date, maxUV: entry.maxUV)
            }
            .sheet(isPresented: $viewModel.showLogSettings) {
                LogSettingsSheet(onSaved: viewModel.onLoggingSaved)
                    .environmentObject(store)
            }
            .onAppear {
                viewModel.configure(store: store)
            }
        }
    }

    private var chartSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "chart.xyaxis.line",
                    title: "Past 30 Days",
                    subtitle: "Maximum daily UV trend",
                    trailing: viewModel.chartEntries.isEmpty ? nil : "Live"
                )

                if viewModel.chartEntries.isEmpty {
                    AppEmptyState(
                        icon: "sun.min.fill",
                        title: "No UV history yet!",
                        message: "Enable exposure logging for meaningful data.",
                        actionTitle: "Log Settings"
                    ) {
                        viewModel.openLogSettings()
                    }
                } else {
                    Chart(viewModel.chartEntries) { entry in
                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("UV", entry.maxUV)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("AppAccent").opacity(0.35), Color("AppAccent").opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("UV", entry.maxUV)
                        )
                        .foregroundStyle(Color("AppPrimary"))
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("UV", entry.maxUV)
                        )
                        .foregroundStyle(Color("AppAccent"))
                        .symbolSize(28)
                    }
                    .chartYScale(domain: 0...11)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color("AppTextSecondary").opacity(0.2))
                            AxisValueLabel()
                                .foregroundStyle(Color("AppTextSecondary"))
                                .font(.caption2)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: [0, 3, 6, 9, 11]) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color("AppTextSecondary").opacity(0.2))
                            AxisValueLabel()
                                .foregroundStyle(Color("AppTextSecondary"))
                                .font(.caption2)
                        }
                    }
                    .frame(height: 210)
                }
            }
        }
    }

    private var listSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(
                    icon: "list.bullet.rectangle",
                    title: "Daily Records",
                    subtitle: "Tap a day for details",
                    trailing: viewModel.sortedEntries.isEmpty ? nil : "\(viewModel.sortedEntries.count)"
                )

                if viewModel.sortedEntries.isEmpty {
                    Text("No records logged yet.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                } else {
                    VStack(spacing: 8) {
                        ForEach(viewModel.sortedEntries) { entry in
                            NavigationLink(value: entry) {
                                IconValueCell(
                                    icon: "sun.haze.fill",
                                    title: formattedDate(entry.date),
                                    subtitle: UVSimulator.uvLabel(for: Int(entry.maxUV.rounded())),
                                    value: String(format: "%.1f", entry.maxUV),
                                    showChevron: true
                                )
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(TapGesture().onEnded {
                                FeedbackHelper.lightTap()
                            })
                        }
                    }
                }
            }
        }
        .overlay {
            if viewModel.showSuccessPulse {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color("AppAccent"), lineWidth: 2)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.showSuccessPulse)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
