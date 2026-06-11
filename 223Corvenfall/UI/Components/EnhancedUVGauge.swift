import SwiftUI

struct EnhancedUVGauge: View {
    let level: Int
    var lastUpdated: Date?

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppGradients.glow())
                    .frame(width: 190, height: 190)

                Circle()
                    .stroke(Color("AppBackground").opacity(0.45), lineWidth: 14)
                    .frame(width: 168, height: 168)

                Circle()
                    .trim(from: 0, to: CGFloat(level) / 11.0)
                    .stroke(
                        AppGradients.gaugeRing,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 168, height: 168)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.45, dampingFraction: 0.75), value: level)

                VStack(spacing: 4) {
                    Image(systemName: UVRiskStyle.icon(for: level))
                        .font(.title2)
                        .foregroundStyle(Color("AppAccent"))
                    Text("\(level)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(UVSimulator.uvLabel(for: level))
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .compositingGroup()

            if let lastUpdated {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color("AppAccent"))
                        .frame(width: 6, height: 6)
                    Text("Updated \(relativeTime(lastUpdated))")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .appInset(cornerRadius: 8)
            }
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        return "\(seconds / 3600)h ago"
    }
}
