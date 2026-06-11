import SwiftUI

enum HistorySection: String, CaseIterable, Identifiable {
    case exposureHistory = "History"
    case insights = "Insights"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .exposureHistory: return "chart.line.uptrend.xyaxis"
        case .insights: return "waveform.path.ecg"
        }
    }
}

struct HistoryContainerView: View {
    @State private var section: HistorySection = .exposureHistory

    var body: some View {
        ZStack{
            AppScaffoldBackground()
            
            VStack(spacing: 0) {
                CustomSegmentedControl(
                    options: HistorySection.allCases,
                    title: { $0.rawValue },
                    selection: $section
                )
                .padding()
                
                switch section {
                case .exposureHistory:
                    UVExposureHistoryView()
                case .insights:
                    UVExposureInsightsView()
                }
            }.padding(.bottom, 60)
        }
    }
}
