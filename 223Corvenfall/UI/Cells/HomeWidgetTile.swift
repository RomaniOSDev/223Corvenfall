import SwiftUI

struct HomeWidgetTile<Content: View>: View {
    var imageName: String?
    var spanFullWidth: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageName {
                GeometryReader { geo in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .allowsHitTesting(false)

                AppGradients.imageOverlay
                    .allowsHitTesting(false)
            } else {
                AppSurfaceBackground(cornerRadius: 20, level: .card)
            }

            content()
                .padding(14)
        }
        .frame(maxWidth: .infinity, minHeight: spanFullWidth ? 168 : 148, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .compositingGroup()
        .shadow(
            color: Color("AppBackground").opacity(AppElevationLevel.card.shadowOpacity),
            radius: AppElevationLevel.card.shadowRadius,
            y: AppElevationLevel.card.shadowYOffset
        )
    }
}
