import SwiftUI

struct UVExposureInsightsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = UVExposureInsightsViewModel()

    private let segments = ["daily", "weekly", "monthly"]
    private let segmentLabels = ["Daily", "Weekly", "Monthly"]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppScaffoldBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        periodPicker
                        chartSection
                        recordsList
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 80)
                }

                AppFloatingButton(icon: "plus") {
                    viewModel.openAdd()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 16)

                SuccessCheckmarkOverlay(isVisible: $viewModel.showCheckmark)
            }
            .appScreenStyle(title: "UV Exposure Insights")
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddUVRecordSheet(existingRecord: viewModel.editingRecord) { date, maxIndex, duration, id in
                    viewModel.saveRecord(date: date, maxIndex: maxIndex, duration: duration, existingID: id)
                }
            }
            .onAppear {
                viewModel.configure(store: store)
            }
        }
    }

    private var periodPicker: some View {
        CustomSegmentedControl(
            options: segments,
            title: { segment in
                segmentLabels[segments.firstIndex(of: segment) ?? 0]
            },
            selection: Binding(
                get: { store.selectedView },
                set: { viewModel.setView($0) }
            )
        )
    }

    private var chartSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "waveform.path.ecg",
                    title: "Exposure Trend",
                    subtitle: periodSubtitle,
                    trailing: viewModel.chartData.isEmpty ? nil : "\(viewModel.filteredRecords.count) pts"
                )

                if viewModel.chartData.isEmpty {
                    AppEmptyState(
                        icon: "sun.max.fill",
                        title: "Track your UV exposure to see trends",
                        message: "Add a record to build your chart.",
                        actionTitle: "Add Entry"
                    ) {
                        viewModel.openAdd()
                    }
                } else {
                    InsightsCanvasChart(data: viewModel.chartData)
                        .frame(height: 200)
                }
            }
        }
    }

    private var periodSubtitle: String {
        switch store.selectedView {
        case "daily": return "Today's readings"
        case "monthly": return "This month"
        default: return "Last 7 days"
        }
    }

    private var recordsList: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(
                    icon: "doc.text.fill",
                    title: "Records",
                    subtitle: "Swipe for edit or delete"
                )

                if viewModel.filteredRecords.isEmpty {
                    Text("No records for this period.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                } else {
                    List {
                        ForEach(viewModel.filteredRecords) { record in
                            UVExposureRecordCell(
                                date: record.date,
                                durationMinutes: record.exposureDuration,
                                maxIndex: record.maxIndex
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.delete(record)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    viewModel.openEdit(record)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Color("AppPrimary"))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .frame(height: CGFloat(viewModel.filteredRecords.count) * 88)
                }
            }
        }
    }
}

private struct InsightsCanvasChart: View {
    let data: [(date: Date, value: Float)]

    var body: some View {
        Canvas { context, size in
            guard !data.isEmpty else { return }

            let minDate = data.map(\.date.timeIntervalSince1970).min() ?? 0
            let maxDate = data.map(\.date.timeIntervalSince1970).max() ?? 1
            let range = max(maxDate - minDate, 1)

            if data.count > 1 {
                var areaPath = Path()
                for (index, point) in data.enumerated() {
                    let xRatio = (point.date.timeIntervalSince1970 - minDate) / range
                    let x = CGFloat(xRatio) * size.width
                    let y = size.height - CGFloat(point.value / 11) * size.height * 0.9 - size.height * 0.05
                    if index == 0 {
                        areaPath.move(to: CGPoint(x: x, y: size.height))
                        areaPath.addLine(to: CGPoint(x: x, y: y))
                    } else {
                        areaPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                if let last = data.last {
                    let xRatio = (last.date.timeIntervalSince1970 - minDate) / range
                    areaPath.addLine(to: CGPoint(x: CGFloat(xRatio) * size.width, y: size.height))
                }
                areaPath.closeSubpath()
                context.fill(areaPath, with: .color(Color("AppAccent").opacity(0.2)))

                var linePath = Path()
                for (index, point) in data.enumerated() {
                    let xRatio = (point.date.timeIntervalSince1970 - minDate) / range
                    let x = CGFloat(xRatio) * size.width
                    let y = size.height - CGFloat(point.value / 11) * size.height * 0.9 - size.height * 0.05
                    if index == 0 {
                        linePath.move(to: CGPoint(x: x, y: y))
                    } else {
                        linePath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(linePath, with: .color(Color("AppPrimary")), lineWidth: 2.5)
            }

            for point in data {
                let xRatio = (point.date.timeIntervalSince1970 - minDate) / range
                let x = CGFloat(xRatio) * size.width
                let y = size.height - CGFloat(point.value / 11) * size.height * 0.9 - size.height * 0.05
                context.fill(
                    Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8)),
                    with: .color(Color("AppAccent"))
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("AppBackground").opacity(0.25))
        )
    }
}
