import SwiftUI

/// Static background — no Canvas, rasterized once for smooth scrolling.
struct AppScaffoldBackground: View {
    var body: some View {
        ZStack {
            AppGradients.screenBase

            RadialGradient(
                colors: [
                    Color("AppAccent").opacity(0.14),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 340
            )

            RadialGradient(
                colors: [
                    Color("AppPrimary").opacity(0.1),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 300
            )
        }
       // .drawingGroup(opaque: false)
        .ignoresSafeArea()
    }
}
