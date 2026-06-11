import SwiftUI

struct AppScreenStyle: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                LinearGradient(
                    colors: [
                        Color("AppSurface"),
                        Color("AppSurface").opacity(0.92)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
    }
}

extension View {
    func appScreenStyle(title: String) -> some View {
        modifier(AppScreenStyle(title: title))
    }
}
