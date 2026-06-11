import SwiftUI

/// Elevation tiers — one composited shadow per surface (GPU-friendly).
enum AppElevationLevel {
    /// Nested rows / chips — no shadow, gradient fill only.
    case inset
    /// Standard cards and widgets.
    case card
    /// Hero banners, tab bar, FAB.
    case prominent

    var shadowRadius: CGFloat {
        switch self {
        case .inset: return 0
        case .card: return 8
        case .prominent: return 14
        }
    }

    var shadowYOffset: CGFloat {
        switch self {
        case .inset: return 0
        case .card: return 4
        case .prominent: return 6
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .inset: return 0
        case .card: return 0.28
        case .prominent: return 0.34
        }
    }
}

struct AppSurfaceBackground: View {
    var cornerRadius: CGFloat
    var level: AppElevationLevel

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        shape
            .fill(level == .inset ? AppGradients.insetSurface : AppGradients.cardSurface)
            .overlay {
                shape.fill(AppGradients.topHighlight)
            }
            .overlay {
                shape.strokeBorder(
                    Color("AppAccent").opacity(level == .inset ? 0.1 : 0.2),
                    lineWidth: 1
                )
            }
    }
}

extension View {
    /// Applies gradient surface + optional single shadow. Use once per card.
    func appElevated(
        _ level: AppElevationLevel = .card,
        cornerRadius: CGFloat = 18
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return self
            .background {
                AppSurfaceBackground(cornerRadius: cornerRadius, level: level)
            }
            .clipShape(shape)
            .compositingGroup()
            .shadow(
                color: Color("AppBackground").opacity(level.shadowOpacity),
                radius: level.shadowRadius,
                y: level.shadowYOffset
            )
    }

    /// Inset fill for list rows and nested tiles — zero shadows.
    func appInset(cornerRadius: CGFloat = 14) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return self
            .background {
                AppSurfaceBackground(cornerRadius: cornerRadius, level: .inset)
            }
            .clipShape(shape)
    }

    /// Subtle inner border on image heroes.
    func appImageFrame(cornerRadius: CGFloat = 22) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return self
            .clipShape(shape)
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: [
                            Color("AppAccent").opacity(0.45),
                            Color("AppPrimary").opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
    }
}
