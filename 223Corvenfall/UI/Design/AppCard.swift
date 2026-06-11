import SwiftUI

struct AppCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 18
    var elevation: AppElevationLevel = .card
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appElevated(elevation, cornerRadius: cornerRadius)
    }
}
