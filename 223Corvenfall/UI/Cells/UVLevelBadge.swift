import SwiftUI

struct UVLevelBadge: View {
    let level: Int
    var style: Style = .compact

    enum Style {
        case compact
        case hero
    }

    var body: some View {
        switch style {
        case .compact:
            compactBadge
        case .hero:
            heroBadge
        }
    }

    private var compactBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: UVRiskStyle.icon(for: level))
                .font(.caption2)
            Text("UV \(level)")
                .font(.caption.bold())
        }
        .foregroundStyle(Color("AppBackground"))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(AppGradients.selectedSegment))
        .compositingGroup()
        .shadow(color: Color("AppBackground").opacity(0.18), radius: 3, y: 1)
    }

    private var heroBadge: some View {
        VStack(spacing: 6) {
            Text("\(level)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(UVSimulator.uvLabel(for: level))
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppAccent"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .appInset(cornerRadius: 16)
    }
}

enum UVRiskStyle {
    static func icon(for level: Int) -> String {
        switch level {
        case 0...2: return "sun.min.fill"
        case 3...5: return "sun.max.fill"
        case 6...7: return "sun.haze.fill"
        default: return "exclamationmark.triangle.fill"
        }
    }

    static func fillOpacity(for level: Int) -> Double {
        switch level {
        case 0...2: return 0.55
        case 3...5: return 0.7
        case 6...7: return 0.85
        default: return 1
        }
    }
}
