import SwiftUI

/// Static gradient recipes — asset colors only, reused across the app.
enum AppGradients {
    static var screenBase: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground"),
                Color("AppSurface"),
                Color("AppBackground")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardSurface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.88),
                Color("AppBackground").opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var insetSurface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground").opacity(0.38),
                Color("AppBackground").opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButton: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent"),
                Color("AppPrimary"),
                Color("AppPrimary").opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var selectedSegment: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent"), Color("AppPrimary")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var heroOverlay: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground").opacity(0.08),
                Color("AppBackground").opacity(0.55),
                Color("AppBackground").opacity(0.9)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var imageOverlay: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground").opacity(0.1),
                Color("AppBackground").opacity(0.5),
                Color("AppBackground").opacity(0.88)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var topHighlight: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppTextPrimary").opacity(0.1),
                Color("AppTextPrimary").opacity(0.02),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var gaugeRing: AngularGradient {
        AngularGradient(
            colors: [
                Color("AppPrimary"),
                Color("AppAccent"),
                Color("AppPrimary")
            ],
            center: .center
        )
    }

    static func glow(center: UnitPoint = .center) -> RadialGradient {
        RadialGradient(
            colors: [
                Color("AppAccent").opacity(0.22),
                Color.clear
            ],
            center: center,
            startRadius: 0,
            endRadius: 120
        )
    }
}
